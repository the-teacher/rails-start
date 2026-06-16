module Ai
  module TribunalEvents
    extend ActiveSupport::Concern

    def tribunal_start_event(count)
      {
        event: "tribunal_start",
        text:  "Tribunal started — launching #{count} agents in parallel…",
        level: "info"
      }
    end

    def tribunal_agent_start_event(index, models)
      model = models[index]
      {
        event: "agent_start",
        text:  "Agent #{index + 1} launched: #{model}",
        level: "info",
        index: index,
        model: model
      }
    end

    def tribunal_agent_done_event(result, index)
      polite = result.processed&.dig("result") == true
      {
        event:  "agent_done",
        text:   "Agent #{index + 1} done: #{result.model&.name} (#{result.execution_time}s) — #{polite ? "Polite" : "Not polite"}",
        level:  polite ? "success" : "warning",
        index:  index,
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  result.usage ? { input: result.usage.tokens.input, output: result.usage.tokens.output, total: result.usage.tokens.total } : nil,
        cost:   result.usage&.cost&.total,
        result: result.processed&.dig("result"),
        reason: result.processed&.dig("reason")
      }
    end

    def tribunal_agent_error_event(name, err, index)
      {
        event: "agent_error",
        text:  "Agent #{(index || 0) + 1} error (#{name.to_s.split('::').last}): #{err.message}",
        level: "error",
        index: index
      }
    end

    def tribunal_all_done_event
      {
        event: "all_done",
        text:  "All agents finished — computing verdict…",
        level: "info"
      }
    end

    def tribunal_verdict_event(verdict)
      {
        event:   "verdict",
        text:    verdict ? "✓ Polite" : "✗ Not polite",
        level:   verdict ? "success" : "error",
        verdict: verdict
      }
    end

    def tribunal_generic_event(name)
      {
        event: name.to_s,
        text:  name.to_s,
        level: "info"
      }
    end

    # ── stream builders ───────────────────────────────────────────────────────

    def build_tribunal_stream(sse)
      lambda do |source, event, *args|
        payload = case source
                  when :tribunal then tribunal_lifecycle_event(event, args).merge(source: "tribunal")
                  when :agent    then tribunal_agent_lifecycle_event(event, args).merge(source: "agent")
                  end
        sse.write(payload.to_json) if payload
        logger.debug "[#{source}] event=#{event} args=#{args.inspect}"
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def tribunal_lifecycle_event(name, args)
      case name
      when :tribunal_start then tribunal_start_event(args[0])
      when :agent_start    then tribunal_agent_start_event(args[0], PolitenessTribunal::MODELS)
      when :agent_done     then tribunal_agent_done_event(args[0], args[1])
      when :agent_error    then tribunal_agent_error_event(args[0], args[1], args[2])
      when :all_done       then tribunal_all_done_event
      when :verdict        then tribunal_verdict_event(args[0])
      else                      tribunal_generic_event(name)
      end
    end

    def tribunal_agent_lifecycle_event(name, args)
      case name
      when :before_call then { event: "before_call", text: "Agent: sending request…",          level: "info"    }
      when :after_call  then { event: "after_call",  text: "Agent: response received",          level: "success" }
      when :retry       then { event: "retry",       text: "Agent: retrying — #{args[1]&.message}", level: "warning" }
      when :failure     then { event: "failure",     text: "Agent: all models failed",          level: "error"   }
      else                   tribunal_generic_event(name)
      end
    end
  end
end
