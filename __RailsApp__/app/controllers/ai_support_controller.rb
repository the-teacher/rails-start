class AiSupportController < ApplicationController
  include ActionController::Live
  layout "ai"

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
    agent = SupportAgent.call(input: params.require(:input))

    render json: {
      output: agent.result.output,
      model:  agent.result.model,
      time:   agent.result.execution_time
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
    agent  = SupportAgent.call(input: params.require(:input), memory: memory)

    render json: {
      output: agent.result.output,
      model:  agent.result.model,
      time:   agent.result.execution_time,
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
    prepare_sse_response

    input = params.require(:input)

    stream        = response.stream
    sse_tokens    = ActionController::Live::SSE.new(stream, event: "message")
    sse_lifecycle = ActionController::Live::SSE.new(stream, event: "lifecycle")

    token_stream = ->(token) { sse_tokens.write({ token: token }.to_json) }

    event_stream = ->(name, *args) do
      sse_lifecycle.write(lifecycle_message(name, args).to_json)
    rescue IOError, ActionController::Live::ClientDisconnected
    end

    SupportAgent.call(
      input:        input,
      token_stream: token_stream,
      event_stream: event_stream
    )

    sse_tokens.write({ done: true }.to_json)
  rescue ActionController::Live::ClientDisconnected
    # client closed the connection — normal, nothing to do
  rescue StandardError => e
    # send the error to the browser so it appears in the output box
    sse_tokens.write({ error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    sse_tokens.write({ done: true }.to_json) rescue nil
  ensure
    sse_tokens.close
  end

  private

  def prepare_sse_response
    # ActionDispatch::ServerTiming crashes with ActionController::Live on Rails 8
    # because the events array is nil when the stream runs on a separate thread.
    request.env["action_dispatch.server_timing_events"] ||= []

    # Tell the browser this is a streaming SSE response, not a regular HTTP response.
    response.headers["Content-Type"]  = "text/event-stream"

    # Disable HTTP caching — every connection must reach the server.
    response.headers["Cache-Control"] = "no-cache"

    # Disable nginx / proxy buffering so tokens reach the browser immediately.
    response.headers["X-Accel-Buffering"] = "no"
  end

  def lifecycle_message(event, args)
    case event
    when :setup
      { event: "setup",
        text:  "Agent initialized",
        level: "info" }
    when :before_system_prompt
      { event: "before_system_prompt",
        text:  "Building system prompt…",
        level: "info" }
    when :after_system_prompt
      { event: "after_system_prompt",
        text:  "System prompt ready",
        level: "info" }
    when :before_call
      { event: "before_call",
        text:  "Sending request…",
        level: "info" }
    when :after_call
      result = args[0]
      { event: "after_call",
        text:  "Response received (#{result.execution_time}s)",
        level: "success",
        model: result.model,
        time:  result.execution_time }
    when :retry
      entry, error = args
      { event: "retry",
        text:  "Retry: #{entry[:model]} — #{error.class.name.split("::").last}",
        level: "warning" }
    when :failure
      { event: "failure",
        text:  "All models failed",
        level: "error" }
    else
      { event: event.to_s,
        text:  event.to_s,
        level: "info" }
    end
  end
end
