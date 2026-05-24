class AiSupportController < ApplicationController
  include ActionController::Live

  skip_before_action :verify_authenticity_token

  # ---------------------------------------------------------------------------
  # GET /ai/support
  # ---------------------------------------------------------------------------
  def index
  end

  # ---------------------------------------------------------------------------
  # POST /ai/agent
  # body: { input: "What is your return policy?" }
  # ---------------------------------------------------------------------------
  def agent
    result = SupportAgent.call(input: params.require(:input))

    render json: {
      output: result.output,
      model:  result.model,
      time:   result.execution_time
    }
  end

  # ---------------------------------------------------------------------------
  # POST /ai/agent_memory
  # body: { input: "Does that apply to accessories?", session_id: "user_42" }
  #
  # Uses AppMemory so the same session keeps conversational context
  # across multiple requests.
  # ---------------------------------------------------------------------------
  def agent_memory
    memory = AppMemory.new(session_id: params.require(:session_id))
    result = SupportAgent.call(input: params.require(:input), memory: memory)

    render json: {
      output: result.output,
      model:  result.model,
      time:   result.execution_time,
      turns:  memory.size
    }
  end

  # ---------------------------------------------------------------------------
  # POST /ai/tribunal
  # body: { input: "Buy cheap pills now!!!" }
  #
  # Returns verdict: true (safe) or false (rejected).
  # ---------------------------------------------------------------------------
  def tribunal
    result = SupportGuardTribunal.call(input: params.require(:input))

    render json: {
      verdict: result.verdict,
      time:    result.execution_time
    }
  end

  # ---------------------------------------------------------------------------
  # POST /ai/pipeline
  # body: { input: "What is your return policy?" }
  #
  # Runs the full TestSupportPipeline.
  # If a guard step stops the pipeline early, stopped: true is returned.
  # ---------------------------------------------------------------------------
  def pipeline
    pipe = SupportPipeline.new(input: params.require(:input))
    pipe.call

    if pipe.stopped?
      render json: { stopped: true, stopped_at: pipe.stopped_at }
    else
      render json: { stopped: false, output: pipe.output }
    end
  end

  # ---------------------------------------------------------------------------
  # GET /ai/agent_stream?input=What+is+your+return+policy%3F
  #
  # Streams response tokens (event: message) AND agent lifecycle events
  # (event: lifecycle) over a single SSE connection.
  #
  # Token frame:     event: message  /  data: {"token":"..."}
  # Done frame:      event: message  /  data: {"done":true}
  # Lifecycle frame: event: lifecycle / data: {"event":"setup","text":"...","level":"info"}
  # ---------------------------------------------------------------------------
  def agent_stream
    # Fix: ActionDispatch::ServerTiming crashes with ActionController::Live on Rails 8
    # because events array is nil when the stream runs on a separate thread.
    request.env["action_dispatch.server_timing_events"] ||= []

    input = params.require(:input)

    response.headers["Content-Type"]  = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no"  # disable nginx buffering

    stream = response.stream
    sse    = ActionController::Live::SSE.new(stream, event: "message")

    event_sink = ->(name, *args) do
      msg = lifecycle_message(name, args)
      stream.write("event: lifecycle\ndata: #{msg.to_json}\n\n")
    rescue IOError, ActionController::Live::ClientDisconnected
      # stream already closed — ignore
    end

    SupportAgent.call(
      input:      input,
      event_sink: event_sink,
      stream:     ->(token) { sse.write({ token: token }.to_json) }
    )

    sse.write({ done: true }.to_json)
  rescue ActionController::Live::ClientDisconnected
    # client closed the connection — normal, nothing to do
  rescue StandardError => e
    # send the error to the browser so it appears in the output box
    sse.write({ error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    sse.write({ done: true }.to_json) rescue nil
  ensure
    sse.close
  end

  private

  def lifecycle_message(event, args)
    case event
    when :setup
      { event: "setup",               text: "Agent initialized",       level: "info" }
    when :before_system_prompt
      { event: "before_system_prompt", text: "Building system prompt…", level: "info" }
    when :after_system_prompt
      { event: "after_system_prompt",  text: "System prompt ready",     level: "info" }
    when :before_call
      { event: "before_call",          text: "Sending request…",        level: "info" }
    when :after_call
      result = args[0]
      { event: "after_call", text: "Response received (#{result.execution_time}s)",
        level: "success", model: result.model, time: result.execution_time }
    when :retry
      entry, error = args
      { event: "retry",
        text:  "Retry: #{entry[:model]} — #{error.class.name.split("::").last}",
        level: "warning" }
    when :failure
      { event: "failure", text: "All models failed", level: "error" }
    else
      { event: event.to_s, text: event.to_s, level: "info" }
    end
  end
end
