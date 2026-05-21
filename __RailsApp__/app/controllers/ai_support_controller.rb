class AiSupportController < ApplicationController
  include ActionController::Live

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
  # Streams the response token by token using Server-Sent Events.
  # Each token arrives as:   data: {"token":"..."}
  # End of stream is marked: data: {"done":true}
  #
  # JavaScript client example:
  #   const es = new EventSource('/ai/agent_stream?input=Hello');
  #   es.onmessage = ({ data }) => {
  #     const { token, done } = JSON.parse(data);
  #     if (done) { es.close(); return; }
  #     document.querySelector('#output').insertAdjacentText('beforeend', token);
  #   };
  # ---------------------------------------------------------------------------
  def agent_stream
    input = params.require(:input)

    response.headers["Content-Type"]  = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no"  # disable nginx buffering

    sse = ActionController::Live::SSE.new(response.stream, event: "message")

    SupportAgent.call(
      input:  input,
      stream: ->(token) { sse.write({ token: token }.to_json) }
    )

    sse.write({ done: true }.to_json)
  rescue ActionController::Live::ClientDisconnected
    # client closed the connection — normal, nothing to do
  ensure
    sse.close
  end
end
