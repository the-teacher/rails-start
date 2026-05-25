module Ai
  class TribunalsController < ApplicationController
    include ActionController::Live
    layout "ai"

    skip_before_action :verify_authenticity_token

    # ---------------------------------------------------------------------------
    # GET /ai/tribunals/politeness
    # Tribunal 1: Politeness — 1 agent × 3 models run in parallel.
    # ---------------------------------------------------------------------------
    def politeness
    end

    # POST /ai/tribunals/politeness/call
    # body: { input: "..." }
    # Returns: { verdict: true/false, results: [...], time: ... }
    def politeness_call
      input    = params.require(:input)
      tribunal = PolitenessTribunal.new(input: input)
      tribunal.call

      results = tribunal.results.map.with_index do |r, i|
        {
          index:  i,
          model:  r.model,
          result: r.parsed&.dig("result"),
          reason: r.parsed&.dig("reason"),
          time:   r.execution_time,
          usage:  r.usage,
          cost:   r.cost
        }
      end

      render json: {
        verdict: tribunal.verdict,
        time:    tribunal.execution_time,
        errors:  tribunal.errors.map { |e| { agent: e[:agent], error: e[:error].message } },
        results: results
      }
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # ---------------------------------------------------------------------------
    # GET /ai/tribunals/politeness/lifecycle
    # Tribunal 2: Politeness + live event sidebar via SSE.
    # ---------------------------------------------------------------------------
    def politeness_lifecycle
    end

    # GET /ai/tribunals/politeness/lifecycle/stream?input=...
    def politeness_lifecycle_stream
      prepare_sse_response

      input = params.require(:input)

      stream     = response.stream
      sse_events = ActionController::Live::SSE.new(stream, event: "lifecycle")
      sse_done   = ActionController::Live::SSE.new(stream, event: "message")

      tribunal_stream = ->(name, *args) do
        logger.debug "[Tribunal] event=#{name} args=#{args.inspect}"
        sse_events.write(tribunal_event_message(name, args).merge(source: "tribunal").to_json)
      rescue IOError, ActionController::Live::ClientDisconnected
      end

      agent_stream = ->(name, *args) do
        logger.debug "[Agent] event=#{name} args=#{args.inspect}"
        sse_events.write(agent_event_message(name, args).merge(source: "agent").to_json)
      rescue IOError, ActionController::Live::ClientDisconnected
      end

      tribunal = PolitenessLifecycleTribunal.new(
        input:                 input,
        tribunal_event_stream: tribunal_stream,
        agent_event_stream:    agent_stream
      )
      tribunal_stream.call(:tribunal_start, PolitenessTribunal::MODELS.size)
      tribunal.call

      sse_done.write({
        done:   true,
        time:   tribunal.execution_time,
        errors: tribunal.errors.map { |e| { agent: e[:agent], error: e[:error].message } }
      }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
      sse_done.write({ done: true }.to_json) rescue nil
    ensure
      sse_done.close
    end

    def agent_event_message(event, args)
      case event
      when :llm_request
        { event: "llm_request",
          text:  "#{args[0]&.split('::')&.last}: sending request…",
          level: "info" }
      when :llm_response
        result = args[0]
        { event: "llm_response",
          text:  "#{result.model}: response received (#{result.execution_time}s)",
          level: "success" }
      when :llm_retry
        model, err = args
        { event: "llm_retry",
          text:  "#{model}: retrying — #{err.message}",
          level: "warning" }
      else
        { event: event.to_s, text: event.to_s, level: "info" }
      end
    end

    private

    def prepare_sse_response
      request.env["action_dispatch.server_timing_events"] ||= []
      response.headers["Content-Type"]      = "text/event-stream"
      response.headers["Cache-Control"]     = "no-cache"
      response.headers["X-Accel-Buffering"] = "no"
    end

    def tribunal_event_message(event, args)
      case event
      when :tribunal_start
        count = args[0]
        { event: "tribunal_start",
          text:  "Tribunal started — launching #{count} agents in parallel…",
          level: "info" }
      when :agent_start
        index = args[0]
        model = PolitenessTribunal::MODELS[index]
        { event: "agent_start",
          text:  "Agent #{index + 1} launched: #{model}",
          level: "info",
          index: index,
          model: model }
      when :agent_done
        result, index = args
        polite = result.parsed&.dig("result") == true
        { event: "agent_done",
          text:  "Agent #{index + 1} done: #{result.model} (#{result.execution_time}s) — #{polite ? "Polite" : "Not polite"}",
          level: polite ? "success" : "warning",
          index: index,
          model: result.model,
          time:  result.execution_time,
          usage: result.usage,
          cost:  result.cost,
          result: result.parsed&.dig("result"),
          reason: result.parsed&.dig("reason") }
      when :agent_error
        name, err, index = args
        { event: "agent_error",
          text:  "Agent #{(index || 0) + 1} error (#{name.to_s.split("::").last}): #{err.message}",
          level: "error",
          index: index }
      when :all_done
        { event: "all_done",
          text:  "All agents finished — computing verdict…",
          level: "info" }
      when :verdict
        verdict = args[0]
        { event: "verdict",
          text:    verdict ? "✓ Polite" : "✗ Not polite",
          level:   verdict ? "success" : "error",
          verdict: verdict }
      else
        { event: event.to_s, text: event.to_s, level: "info" }
      end
    end
  end
end
