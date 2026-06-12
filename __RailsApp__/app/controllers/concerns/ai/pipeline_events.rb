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

    def tribunal_before_agent_event(args, agent_names)
      _agent, index = args
      label = agent_names[index] || "agent #{(index || 0) + 1}"
      {
        event:  "tribunal_before_agent",
        text:   "Tribunal: launching #{label}…",
        level:  "info",
        source: "tribunal",
        agent:  label,
        index:  index
      }
    end

    def tribunal_after_agent_event(args, agent_names)
      result, index = args
      time         = result.respond_to?(:execution_time) ? result.execution_time : "?"
      cost         = result.respond_to?(:usage)          ? result.usage&.cost&.total : nil
      model        = result.respond_to?(:model)          ? result.model&.name : nil
      detail, lvl  = tribunal_agent_detail(result.respond_to?(:processed) ? result.processed : nil)
      label        = agent_names[index] || "agent #{(index || 0) + 1}"
      {
        event:  "tribunal_after_agent",
        text:   "Tribunal: #{label} done (#{time}s) — #{detail}",
        level:  lvl,
        source: "tribunal",
        agent:  label,
        index:  index,
        time:   time,
        cost:   cost,
        model:  model
      }
    end

    def tribunal_agent_error_event(args)
      _name_str, err, index = args
      {
        event:  "tribunal_agent_error",
        text:   "Tribunal: agent #{(index || 0) + 1} error — #{err&.message}",
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

    # ── agent ─────────────────────────────────────────────────────────────────

    def agent_before_call_event
      {
        event:  "agent_before_call",
        text:   "Agent: sending request…",
        level:  "info",
        source: "agent"
      }
    end

    def agent_after_call_event(result)
      time = result.respond_to?(:execution_time) ? result.execution_time : nil
      {
        event:  "agent_after_call",
        text:   "Agent: response received#{time ? " (#{time}s)" : ""}",
        level:  "success",
        source: "agent"
      }
    end

    def agent_retry_event(args)
      entry, err = args
      {
        event:  "agent_retry",
        text:   "Agent: retrying #{entry&.dig(:model)} — #{err&.message}",
        level:  "warning",
        source: "agent"
      }
    end

    def agent_failure_event
      {
        event:  "agent_failure",
        text:   "Agent: all models failed",
        level:  "error",
        source: "agent"
      }
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

    def tribunal_agent_detail(parsed)
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
