module Ai
  class AgentsController < ApplicationController
    include ActionController::Live
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
        model:  result.model,
        time:   result.execution_time,
        usage:  result.usage
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

      stream = response.stream
      sse    = ActionController::Live::SSE.new(stream, event: "message")

      token_stream = build_token_stream(sse)

      agent = SimpleAgent.call(
        input:        input,
        token_stream: token_stream
      )

      result = agent.result
      sse.write({ done: true, model: result.model, time: result.execution_time, usage: result.usage }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse.write({ error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
      sse.write({ done: true }.to_json) rescue nil
    ensure
      sse.close
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

      stream        = response.stream
      sse_tokens    = ActionController::Live::SSE.new(stream, event: "message")
      sse_lifecycle = ActionController::Live::SSE.new(stream, event: "lifecycle")

      token_stream = build_token_stream(sse_tokens)
      event_stream  = build_event_stream(sse_lifecycle)

      agent = SupportAgent.call(
        input:        input,
        token_stream: token_stream,
        event_stream: event_stream
      )

      sse_tokens.write({ done: true, usage: agent.result.usage }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_tokens.write({ error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
      sse_tokens.write({ done: true }.to_json) rescue nil
    ensure
      sse_tokens.close
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

      stream        = response.stream
      sse_tokens    = ActionController::Live::SSE.new(stream, event: "message")
      sse_lifecycle = ActionController::Live::SSE.new(stream, event: "lifecycle")

      token_stream = build_token_stream(sse_tokens)
      event_stream  = build_event_stream(sse_lifecycle)

      agent = SupportRubyLLMAgent.call(
        input:        input,
        token_stream: token_stream,
        event_stream: event_stream
      )

      sse_tokens.write({ done: true, usage: agent.result.usage }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
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

    def build_token_stream(sse)
      ->(token) { sse.write({ token: token }.to_json) }
    end

    def build_event_stream(sse)
      ->(name, *args) do
        sse.write(lifecycle_event_message(name, args).to_json)
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def lifecycle_event_message(event, args)
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
          time:  result.execution_time,
          usage: result.usage }
      when :retry
        entry, error = args
        { event: "retry",
          text:  "Retry: #{entry[:model]} — #{error.class.name.split('::').last}",
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
end
