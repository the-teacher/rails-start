module Ai
  class AgentsController < ApplicationController
    include ActionController::Live
    include Ai::AgentEvents
    layout "ai"

    skip_before_action :verify_authenticity_token

    # ---------------------------------------------------------------------------
    # GET /ai/agents/simple
    # Case 1: Simple agent — no hooks, no streaming.
    # ---------------------------------------------------------------------------
    def simple
    end

    # POST /ai/agents/simple
    def simple_call
      agent = SimpleAgent.call(input: params.require(:input))

      result = agent.result
      render json: {
        output: result.output,
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  usage_json(result.usage),
        cost:   result.usage&.cost&.total
      }
    end

    # ---------------------------------------------------------------------------
    # GET /ai/agents/streaming
    # Case 2: Same simple agent but with token-by-token streaming via SSE.
    # No lifecycle sidebar.
    # ---------------------------------------------------------------------------
    def streaming
    end

    # GET /ai/agents/streaming/stream?input=...
    def streaming_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      token_stream = build_token_stream(sse_done)

      agent = SimpleAgent.call(
        input:   input,
        streams: { token: token_stream }
      )

      result = agent.result
      sse_done.write({ done: true, model: result.model&.name, time: result.execution_time, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/agents/lifecycle
    # Case 3: Streaming + full lifecycle sidebar with agent hook events.
    # (Kept identical to the original ai/support page)
    # ---------------------------------------------------------------------------
    def lifecycle
    end

    # GET /ai/agents/lifecycle/stream?input=...
    def lifecycle_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      token_stream = build_token_stream(sse_done)
      event_stream = build_agent_event_stream(sse)

      agent = SupportAgent.call(
        input:   input,
        streams: { token: token_stream, agent: event_stream }
      )

      result = agent.result
      sse_done.write({ done: true, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/agents/ruby_llm
    # Case 4: ruby_llm backend — streaming + lifecycle sidebar.
    # Same as Case 3 but HTTP calls go through the ruby_llm gem.
    # ---------------------------------------------------------------------------
    def ruby_llm
    end

    # GET /ai/agents/ruby_llm/stream?input=...
    def ruby_llm_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      token_stream = build_token_stream(sse_done)
      event_stream = build_agent_event_stream(sse)

      agent = SupportRubyLLMAgent.call(
        input:   input,
        streams: { token: token_stream, agent: event_stream }
      )

      result = agent.result
      sse_done.write({ done: true, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/agents/fallback
    # Case 5: Fallback chain demo — 2 intentionally broken models prepended via
    # agent.models.prepend, then SupportRubyLLMAgent's own chain takes over.
    # The lifecycle sidebar shows :retry events for each failed model before
    # the first working model succeeds.
    # ---------------------------------------------------------------------------
    def fallback
    end

    # GET /ai/agents/fallback/stream?input=...
    def fallback_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      token_stream = build_token_stream(sse_done)
      event_stream = build_agent_event_stream(sse)

      agent = SupportRubyLLMAgent.new(
        input:   input,
        streams: { token: token_stream, agent: event_stream }
      )

      # Prepend 2 broken models — they will fail and trigger :retry events in the sidebar.
      agent.models.prepend([
        { provider: :openrouter, model: "fake-provider/broken-model-one" },
        { provider: :openrouter, model: "fake-provider/broken-model-two" }
      ])

      agent.call

      sse_done.write({ done: true, usage: usage_json(agent.result&.usage), cost: agent.result&.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/agents/memory
    # Case 6: Memory agent — conversation history persisted via JsonFile.
    # Each browser session gets its own memory file under storage/ai/memory/sessions/.
    # ---------------------------------------------------------------------------
    def memory
      @session_id = memory_session_id
      mem = AppMemory.new(file_name: "sessions/#{@session_id}")
      mem.load
      @history = mem.turns
    end

    # POST /ai/agents/memory/call
    def memory_call
      mem = AppMemory.new(file_name: "sessions/#{memory_session_id}")

      agent = MemoryAgent.call(
        input:  params.require(:input),
        memory: mem
      )

      result = agent.result
      render json: {
        output: result.output,
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  usage_json(result.usage),
        cost:   result.usage&.cost&.total
      }
    end

    # POST /ai/agents/memory/clear
    def memory_clear
      sid = session[:ai_memory_id]
      if sid
        mem = AppMemory.new(file_name: "sessions/#{sid}")
        mem.load
        mem.delete
        session.delete(:ai_memory_id)
      end
      redirect_to ai_agents_memory_path
    end

    private

    def memory_session_id
      session[:ai_memory_id] ||= SecureRandom.hex(8)
    end

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

    def build_token_stream(sse)
      ->(token) { sse.write({ token: token }.to_json) }
    end

    def usage_json(usage)
      return nil unless usage
      { input: usage.tokens.input, output: usage.tokens.output, total: usage.tokens.total }
    end
  end
end
