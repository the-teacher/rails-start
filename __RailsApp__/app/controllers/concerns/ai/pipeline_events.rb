module Ai
  module PipelineEvents
    extend ActiveSupport::Concern

    LAUNDRY_INNER_STEPS = Set.new(%i[injection_guard translate compact]).freeze

    STEP_LABELS = {
      laundry:         "Prompt Laundry",
      injection_guard: "Injection guard",
      translate:       "Translation",
      compact:         "Compaction",
      safety_tribunal: "Safety tribunal",
      relevance_guard: "Relevance guard",
      respond:         "Response"
    }.freeze

    STEP_KINDS = {
      laundry:         "pipeline",
      safety_tribunal: "tribunal"
    }.freeze

    STEP_DESCRIPTIONS = {
      laundry:         "Sanitising, translating and compacting input…",
      injection_guard: "Checking for prompt injection…",
      translate:       "Translating to English…",
      compact:         "Extracting core intent…",
      safety_tribunal: "Running toxicity + aggression checks in parallel…",
      relevance_guard: "Checking topic relevance…",
      respond:         "Generating answer…"
    }.freeze

    # ── pipeline ─────────────────────────────────────────────────────────────

    def pipeline_step_start_event(step_name, step_index, source = "pipeline")
      {
        event:  "step_start",
        step:   step_name,
        index:  step_index,
        label:  step_label(step_name),
        kind:   STEP_KINDS[step_name&.to_sym],
        text:   "→ #{step_label(step_name)}: #{STEP_DESCRIPTIONS[step_name&.to_sym] || step_name}",
        level:  "info",
        source: source
      }
    end

    def pipeline_step_done_event(step_name, result, source = "pipeline")
      time  = result.respond_to?(:execution_time) ? result.execution_time : nil
      cost  = result.respond_to?(:usage)          ? result.usage&.cost&.total : nil
      model = result.respond_to?(:model)          ? result.model&.name : nil
      extra = step_result_summary(step_name&.to_sym, result)
      {
        event:  "step_done",
        step:   step_name,
        label:  step_label(step_name),
        text:   "✓ #{step_label(step_name)} done#{time ? " (#{time}s)" : ""}#{extra ? " — #{extra}" : ""}",
        level:  "success",
        time:   time,
        cost:   cost,
        model:  model,
        source: source
      }
    end

    def pipeline_stopped_event(step_name, result)
      {
        event:  "stopped",
        step:   step_name,
        text:   "✗ Stopped at #{step_label(step_name)} — #{stop_reason_text(step_name&.to_sym, result)}",
        level:  "error",
        source: "pipeline"
      }
    end

    def pipeline_complete_event(in_laundry = false)
      if in_laundry
        {
          event:  "laundry_complete",
          text:   "✓ Prompt Laundry complete",
          level:  "success",
          source: "laundry"
        }
      else
        {
          event:  "complete",
          text:   "✓ Pipeline complete",
          level:  "success",
          source: "pipeline"
        }
      end
    end

    def pipeline_generic_event(name)
      {
        event:  name.to_s,
        text:   name.to_s,
        level:  "info",
        source: "pipeline"
      }
    end

    # ── tribunal ─────────────────────────────────────────────────────────────

    def tribunal_before_call_event
      {
        event:  "tribunal_before_call",
        text:   "Tribunal: starting…",
        level:  "info",
        source: "tribunal"
      }
    end

    def tribunal_after_call_event
      {
        event:  "tribunal_after_call",
        text:   "Tribunal: finished",
        level:  "success",
        source: "tribunal"
      }
    end

    def tribunal_before_request_event(args, request_names)
      _request, index = args
      label = request_names[index] || "request #{(index || 0) + 1}"
      {
        event:   "tribunal_before_request",
        text:    "Tribunal: launching #{label}…",
        level:   "info",
        source:  "tribunal",
        request: label,
        index:   index
      }
    end

    def tribunal_after_request_event(args, request_names)
      result, index = args
      time         = result.respond_to?(:execution_time) ? result.execution_time : "?"
      cost         = result.respond_to?(:usage)          ? result.usage&.cost&.total : nil
      model        = result.respond_to?(:model)          ? result.model&.name : nil
      detail, lvl  = tribunal_request_detail(result.respond_to?(:processed) ? result.processed : nil)
      label        = request_names[index] || "request #{(index || 0) + 1}"
      {
        event:   "tribunal_after_request",
        text:    "Tribunal: #{label} done (#{time}s) — #{detail}",
        level:   lvl,
        source:  "tribunal",
        request: label,
        index:   index,
        time:    time,
        cost:    cost,
        model:   model
      }
    end

    def tribunal_request_error_event(args)
      _name_str, err, index = args
      {
        event:  "tribunal_request_error",
        text:   "Tribunal: request #{(index || 0) + 1} error — #{err&.message}",
        level:  "error",
        source: "tribunal"
      }
    end

    def tribunal_before_verdict_event
      {
        event:  "tribunal_before_verdict",
        text:   "Tribunal: computing verdict…",
        level:  "info",
        source: "tribunal"
      }
    end

    def tribunal_after_verdict_event(verdict)
      {
        event:  "tribunal_after_verdict",
        text:   "Tribunal verdict: #{verdict ? "✓ PASS" : "✗ FAIL"}",
        level:  verdict ? "success" : "error",
        source: "tribunal"
      }
    end

    def tribunal_generic_event(name)
      {
        event:  name.to_s,
        text:   "Tribunal: #{name}",
        level:  "info",
        source: "tribunal"
      }
    end

    # ── request ─────────────────────────────────────────────────────────────────

    def request_before_call_event
      {
        event:  "request_before_call",
        text:   "Request: sending…",
        level:  "info",
        source: "request"
      }
    end

    def request_after_call_event(result)
      time = result.respond_to?(:execution_time) ? result.execution_time : nil
      {
        event:  "request_after_call",
        text:   "Request: response received#{time ? " (#{time}s)" : ""}",
        level:  "success",
        source: "request"
      }
    end

    def request_retry_event(args)
      entry, err = args
      {
        event:  "request_retry",
        text:   "Request: retrying #{entry&.dig(:model)} — #{err&.message}",
        level:  "warning",
        source: "request"
      }
    end

    def request_failure_event
      {
        event:  "request_failure",
        text:   "Request: all models failed",
        level:  "error",
        source: "request"
      }
    end

    # ── write helpers (take sse, build payload, write) ───────────────────────

    def write_flat_pipeline_event(sse, name, args, step_index)
      sse.write(build_flat_pipeline_event(name, args, step_index).to_json)
    end

    def write_pipeline_event(sse, name, args, step_index, in_laundry = false)
      sse.write(build_pipeline_event(name, args, step_index, in_laundry).to_json)
    end

    def write_tribunal_event(sse, name, args, request_names)
      request_names[args[1]] = args[0].class.name if name == :before_request
      payload = build_tribunal_event(name, args, request_names)
      sse.write(payload.to_json) if payload
    end

    def write_request_event(sse, name, args)
      payload = build_request_event(name, args)
      sse.write(payload.to_json) if payload
    end

    # ── event dispatchers ─────────────────────────────────────────────────────

    def build_flat_pipeline_event(name, args, step_index)
      case name
      when :before_step then pipeline_step_start_event(args[0], step_index, "pipeline")
      when :after_step  then pipeline_step_done_event(args[0], args[1], "pipeline")
      when :stopped     then pipeline_stopped_event(args[0], args[1])
      when :complete    then pipeline_complete_event(false)
      else                   pipeline_generic_event(name)
      end
    end

    def build_pipeline_event(name, args, step_index, in_laundry = false)
      case name
      when :before_step
        source = LAUNDRY_INNER_STEPS.include?(args[0]) ? "laundry" : "pipeline"
        pipeline_step_start_event(args[0], step_index, source)
      when :after_step
        source = LAUNDRY_INNER_STEPS.include?(args[0]) ? "laundry" : "pipeline"
        pipeline_step_done_event(args[0], args[1], source)
      when :stopped  then pipeline_stopped_event(args[0], args[1])
      when :complete then pipeline_complete_event(in_laundry)
      else                pipeline_generic_event(name)
      end
    end

    def build_tribunal_event(name, args, request_names = {})
      case name
      when :before_call    then tribunal_before_call_event
      when :after_call     then tribunal_after_call_event
      when :before_request then tribunal_before_request_event(args, request_names)
      when :after_request  then tribunal_after_request_event(args, request_names)
      when :request_error  then tribunal_request_error_event(args)
      when :before_verdict then tribunal_before_verdict_event
      when :after_verdict  then tribunal_after_verdict_event(args[0])
      else                      tribunal_generic_event(name)
      end
    end

    def build_request_event(name, args)
      case name
      when :setup       then nil
      when :before_call then request_before_call_event
      when :after_call  then request_after_call_event(args[0])
      when :retry       then request_retry_event(args)
      when :failure     then request_failure_event
      else                   nil
      end
    end

    # ── helpers ───────────────────────────────────────────────────────────────

    def step_label(step_name)
      STEP_LABELS[step_name&.to_sym] || step_name.to_s
    end

    def step_result_summary(step_name, result)
      case step_name
      when :laundry
        if result.processed&.dig("stopped")
          inner = result.processed["stopped_at"]
          "BLOCKED at #{inner}"
        else
          truncate_output(result.output, 60)
        end
      when :injection_guard  then result.processed&.dig("detected") ? "INJECTION" : "clean"
      when :translate        then truncate_output(result.output, 60)
      when :compact          then truncate_output(result.output, 60)
      when :safety_tribunal
        v = result.processed&.[]("verdict")
        v.nil? ? nil : (v ? "SAFE" : "UNSAFE")
      when :relevance_guard  then result.processed&.dig("relevant") ? "relevant" : "off-topic"
      when :respond          then truncate_output(result.output, 80)
      end
    end

    def stop_reason_text(step_name, result)
      case step_name
      when :laundry
        inner = result.processed&.dig("stopped_at")
        inner == "injection_guard" ? "injection detected" : "input blocked at #{inner}"
      when :injection_guard
        result.processed&.dig("reason") || "injection detected"
      when :safety_tribunal
        "content failed safety check"
      when :relevance_guard
        result.processed&.dig("reason") || "off-topic"
      else
        "condition met"
      end
    end

    def tribunal_request_detail(parsed)
      return ["no data", "info"] unless parsed.is_a?(Hash)

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

    def truncate_output(str, max)
      out = str.to_s.gsub(/\s+/, " ").strip
      out.length > max ? out[0..max] + "…" : out
    end
  end
end
