module Ai
  class TribunalsController < ApplicationController
    include ActionController::Live
    include Ai::TribunalEvents
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
          model:  r.model&.name,
          result: r.processed&.dig("result"),
          reason: r.processed&.dig("reason"),
          time:   r.execution_time,
          usage:  r.usage ? { input: r.usage.tokens.input, output: r.usage.tokens.output, total: r.usage.tokens.total } : nil,
          cost:   r.usage&.cost&.total
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
      sse_events = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done   = ActionController::Live::SSE.new(stream, event: "completion")

      tribunal_stream = build_tribunal_stream(sse_events)
      agent_stream     = build_tribunal_agent_stream(sse_events)

      tribunal = PolitenessLifecycleTribunal.new(
        input:   input,
        streams: { tribunal: tribunal_stream, agent: agent_stream }
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

    private

    def prepare_sse_response
      request.env["action_dispatch.server_timing_events"] ||= []
      response.headers["Content-Type"]      = "text/event-stream"
      response.headers["Cache-Control"]     = "no-cache"
      response.headers["X-Accel-Buffering"] = "no"
    end
  end
end

