module Ai
  class PipelinesController < ApplicationController
    include ActionController::Live
    layout "ai"

    skip_before_action :verify_authenticity_token

    STEP_LABELS = {
      injection_guard: "Injection guard",
      translate:       "Translation",
      compact:         "Compaction",
      safety_tribunal: "Safety tribunal",
      relevance_guard: "Relevance guard",
      respond:         "Response"
    }.freeze

    STEP_DESCRIPTIONS = {
      injection_guard: "Checking for prompt injection…",
      translate:       "Translating to English…",
      compact:         "Extracting core intent…",
      safety_tribunal: "Running toxicity + aggression checks in parallel…",
      relevance_guard: "Checking topic relevance…",
      respond:         "Generating answer…"
    }.freeze

    # GET /ai/pipelines/support
    def support
    end

    # GET /ai/pipelines/support/stream?input=...
    def support_stream
      prepare_sse_response

      input    = params.require(:input)
      sse      = ActionController::Live::SSE.new(response.stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(response.stream, event: "completion")

      @step_index           = 0
      @tribunal_agent_names = {}

      pipeline = SupportPipeline.new(
        input:   input,
        streams: {
          pipeline: pipeline_stream(sse),
          tribunal: tribunal_stream(sse),
          agent:    agent_stream(sse)
        }
      )
      pipeline.call

      sse_done.write({
        done:       true,
        stopped:    pipeline.stopped?,
        stopped_at: pipeline.stopped_at,
        output:     pipeline.output,
        time:       pipeline.execution_time
      }.to_json)
    rescue ActionController::Live::ClientDisconnected
      # ignore
    rescue StandardError => e
      sse_done.write({ error: "#{e.class.name.split("::").last}: #{e.message}" }.to_json) rescue nil
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

    def pipeline_stream(sse)
      lambda do |name, *args|
        write_pipeline_event(sse, name, args, @step_index)
        @step_index += 1 if name == :before_step
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def tribunal_stream(sse)
      lambda do |name, *args|
        write_tribunal_event(sse, name, args, @tribunal_agent_names)
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def agent_stream(sse)
      lambda do |name, *args|
        write_agent_event(sse, name, args)
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def write_pipeline_event(sse, name, args, step_index)
      payload = build_pipeline_event(name, args, step_index)
      sse.write(payload.to_json)
    end

    def write_tribunal_event(sse, name, args, agent_names)
      agent_names[args[1]] = args[0].class.name.delete_suffix("Agent") if name == :before_agent
      payload = build_tribunal_event(name, args, agent_names)
      sse.write(payload.to_json) if payload
    end

    def write_agent_event(sse, name, args)
      payload = build_agent_event(name, args)
      sse.write(payload.to_json) if payload
    end

    def build_pipeline_event(name, args, step_index)
      case name
      when :before_step
        step_name = args[0]
        desc      = STEP_DESCRIPTIONS[step_name] || step_name.to_s
        { event:  "step_start",
          step:   step_name,
          index:  step_index,
          label:  STEP_LABELS[step_name] || step_name.to_s,
          text:   "→ #{STEP_LABELS[step_name] || step_name}: #{desc}",
          level:  "info",
          source: "pipeline" }
      when :after_step
        step_name, result = args
        time  = result.respond_to?(:execution_time) ? result.execution_time : nil
        extra = step_result_summary(step_name, result)
        { event:  "step_done",
          step:   step_name,
          label:  STEP_LABELS[step_name] || step_name.to_s,
          text:   "✓ #{STEP_LABELS[step_name] || step_name} done#{time ? " (#{time}s)" : ""}#{extra ? " — #{extra}" : ""}",
          level:  "success",
          time:   time,
          source: "pipeline" }
      when :stopped
        step_name, result = args
        reason = stop_reason_text(step_name, result)
        { event:  "stopped",
          step:   step_name,
          text:   "✗ Stopped at #{STEP_LABELS[step_name] || step_name} — #{reason}",
          level:  "error",
          source: "pipeline" }
      when :complete
        { event:  "complete",
          text:   "✓ Pipeline complete",
          level:  "success",
          source: "pipeline" }
      else
        { event: name.to_s, text: name.to_s, level: "info", source: "pipeline" }
      end
    end

    def build_tribunal_event(name, args, agent_names = {})
      case name
      when :before_call
        { event: "tribunal_before_call", text: "Tribunal: starting…", level: "info", source: "tribunal" }
      when :after_call
        { event: "tribunal_after_call", text: "Tribunal: finished", level: "success", source: "tribunal" }
      when :before_agent
        _agent, index = args
        label = agent_names[index] || "agent #{(index || 0) + 1}"
        { event: "tribunal_before_agent", text: "Tribunal: launching #{label}…",
          level: "info", source: "tribunal" }
      when :after_agent
        result, index = args
        time   = result.respond_to?(:execution_time) ? result.execution_time : "?"
        parsed = result.respond_to?(:parsed) ? result.parsed : nil
        detail, lvl = tribunal_agent_detail(parsed)
        label = agent_names[index] || "agent #{(index || 0) + 1}"
        { event: "tribunal_after_agent",
          text:  "Tribunal: #{label} done (#{time}s) — #{detail}",
          level: lvl, source: "tribunal" }
      when :agent_error
        name_str, err, index = args
        { event: "tribunal_agent_error",
          text:  "Tribunal: agent #{(index || 0) + 1} error — #{err&.message}",
          level: "error", source: "tribunal" }
      when :before_verdict
        { event: "tribunal_before_verdict", text: "Tribunal: computing verdict…", level: "info", source: "tribunal" }
      when :after_verdict
        verdict = args[0]
        { event: "tribunal_after_verdict",
          text:  "Tribunal verdict: #{verdict ? "✓ PASS" : "✗ FAIL"}",
          level: verdict ? "success" : "error", source: "tribunal" }
      else
        { event: name.to_s, text: "Tribunal: #{name}", level: "info", source: "tribunal" }
      end
    end

    def build_agent_event(name, args)
      case name
      when :setup
        nil  # too noisy, skip
      when :before_call
        { event: "agent_before_call", text: "Agent: sending request…", level: "info", source: "agent" }
      when :after_call
        result = args[0]
        time   = result.respond_to?(:execution_time) ? result.execution_time : nil
        { event: "agent_after_call",
          text:  "Agent: response received#{time ? " (#{time}s)" : ""}",
          level: "success", source: "agent" }
      when :retry
        entry, err = args
        { event: "agent_retry",
          text:  "Agent: retrying #{entry&.dig(:model)} — #{err&.message}",
          level: "warning", source: "agent" }
      when :failure
        { event: "agent_failure", text: "Agent: all models failed", level: "error", source: "agent" }
      else
        nil
      end
    end

    def step_result_summary(step_name, result)
      case step_name
      when :injection_guard
        result.parsed&.dig("detected") ? "INJECTION" : "clean"
      when :translate
        out = result.output.to_s.gsub(/\s+/, " ").strip
        out.length > 60 ? out[0..60] + "…" : out
      when :compact
        out = result.output.to_s.gsub(/\s+/, " ").strip
        out.length > 60 ? out[0..60] + "…" : out
      when :safety_tribunal
        v = result.respond_to?(:verdict) ? result.verdict : nil
        v.nil? ? nil : (v ? "SAFE" : "UNSAFE")
      when :relevance_guard
        result.parsed&.dig("relevant") ? "relevant" : "off-topic"
      when :respond
        out = result.output.to_s.gsub(/\s+/, " ").strip
        out.length > 80 ? out[0..80] + "…" : out
      end
    end

    def stop_reason_text(step_name, result)
      case step_name
      when :injection_guard
        result.parsed&.dig("reason") || "injection detected"
      when :safety_tribunal
        "content failed safety check"
      when :relevance_guard
        result.parsed&.dig("reason") || "off-topic"
      else
        "condition met"
      end
    end

    # Returns [text_detail, log_level] for a single tribunal agent result.
    # Extracts the named boolean field ("toxic", "aggressive", etc.) and optional "reason".
    def tribunal_agent_detail(parsed)
      return ["no data", "info"] unless parsed.is_a?(Hash)

      # Find the first boolean flag field (toxic, aggressive, …)
      flag_key, flag_val = parsed.find { |k, v| v == true || v == false }

      unless flag_key
        snippet = parsed.to_s[0..50]
        return [snippet, "info"]
      end

      reason = parsed["reason"].to_s.strip
      reason = reason.empty? ? nil : reason[0..60]

      if flag_val == false
        detail = "#{flag_key}: ✓ ok"
        [reason ? "#{detail} — #{reason}" : detail, "success"]
      else
        detail = "#{flag_key}: ✗ detected"
        [reason ? "#{detail} — #{reason}" : detail, "warning"]
      end
    end
  end
end
