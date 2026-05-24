module Ai
  class AgentsController < ApplicationController
    include ActionController::Live

    skip_before_action :verify_authenticity_token

    # ---------------------------------------------------------------------------
    # GET /ai/agents/simple
    # Case 1: Simple agent — no hooks, no streaming.
    # ---------------------------------------------------------------------------
    def simple
    end

    # POST /ai/agents/simple
    def simple_call
      result = SimpleAgent.call(input: params.require(:input))
      render json: { output: result.output, model: result.model, time: result.execution_time }
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
      request.env["action_dispatch.server_timing_events"] ||= []

      input = params.require(:input)
      response.headers["Content-Type"]     = "text/event-stream"
      response.headers["Cache-Control"]    = "no-cache"
      response.headers["X-Accel-Buffering"] = "no"

      stream = response.stream
      sse    = ActionController::Live::SSE.new(stream, event: "message")

      SimpleAgent.call(
        input:  input,
        stream: ->(token) { sse.write({ token: token }.to_json) }
      )
      sse.write({ done: true }.to_json)
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
      request.env["action_dispatch.server_timing_events"] ||= []

      input = params.require(:input)
      response.headers["Content-Type"]     = "text/event-stream"
      response.headers["Cache-Control"]    = "no-cache"
      response.headers["X-Accel-Buffering"] = "no"

      stream = response.stream
      sse    = ActionController::Live::SSE.new(stream, event: "message")

      event_sink = ->(name, *args) do
        msg = lifecycle_event_message(name, args)
        stream.write("event: lifecycle\ndata: #{msg.to_json}\n\n")
      rescue IOError, ActionController::Live::ClientDisconnected
      end

      SupportAgent.call(
        input:      input,
        event_sink: event_sink,
        stream:     ->(token) { sse.write({ token: token }.to_json) }
      )
      sse.write({ done: true }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse.write({ error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
      sse.write({ done: true }.to_json) rescue nil
    ensure
      sse.close
    end

    private

    def lifecycle_event_message(event, args)
      case event
      when :setup
        { event: "setup",                text: "Agent initialized",        level: "info" }
      when :before_system_prompt
        { event: "before_system_prompt", text: "Building system prompt…",  level: "info" }
      when :after_system_prompt
        { event: "after_system_prompt",  text: "System prompt ready",      level: "info" }
      when :before_call
        { event: "before_call",          text: "Sending request…",         level: "info" }
      when :after_call
        result = args[0]
        { event: "after_call", text: "Response received (#{result.execution_time}s)",
          level: "success", model: result.model, time: result.execution_time }
      when :retry
        entry, error = args
        { event: "retry",
          text:  "Retry: #{entry[:model]} — #{error.class.name.split('::').last}",
          level: "warning" }
      when :failure
        { event: "failure", text: "All models failed", level: "error" }
      else
        { event: event.to_s, text: event.to_s, level: "info" }
      end
    end
  end
end
