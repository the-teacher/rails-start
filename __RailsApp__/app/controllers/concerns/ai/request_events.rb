module Ai
  module RequestEvents
    extend ActiveSupport::Concern

    def request_setup_event
      {
        event: "setup",
        text:  "Request initialized",
        level: "info"
      }
    end

    def request_before_system_prompt_event
      {
        event: "before_system_prompt",
        text:  "Building system prompt…",
        level: "info"
      }
    end

    def request_after_system_prompt_event
      {
        event: "after_system_prompt",
        text:  "System prompt ready",
        level: "info"
      }
    end

    def request_before_call_event
      {
        event: "before_call",
        text:  "Sending request…",
        level: "info"
      }
    end

    def request_after_call_event(result)
      {
        event: "after_call",
        text:  "Response received (#{result.execution_time}s)",
        level: "success",
        model: result.model&.name,
        time:  result.execution_time,
        usage: result.usage ? { input: result.usage.tokens.input, output: result.usage.tokens.output, total: result.usage.tokens.total } : nil,
        cost:  result.usage&.cost&.total
      }
    end

    def request_retry_event(entry, error)
      {
        event: "retry",
        text:  "Retry: #{entry[:model]} — #{error.class.name.split('::').last}",
        level: "warning"
      }
    end

    def request_failure_event
      {
        event: "failure",
        text:  "All models failed",
        level: "error"
      }
    end

    def request_generic_event(name)
      {
        event: name.to_s,
        text:  name.to_s,
        level: "info"
      }
    end

    # ── stream builders ───────────────────────────────────────────────────────

    def build_token_stream(sse)
      ->(token) { sse.write({ token: token }.to_json) }
    end

    def build_request_event_stream(sse)
      lambda do |_source, event, *args|
        payload = request_lifecycle_event(event, args)
        sse.write(payload.to_json)
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def request_lifecycle_event(name, args)
      case name
      when :setup                 then request_setup_event
      when :before_system_prompt  then request_before_system_prompt_event
      when :after_system_prompt   then request_after_system_prompt_event
      when :before_call           then request_before_call_event
      when :after_call            then request_after_call_event(args[0])
      when :retry                 then request_retry_event(args[0], args[1])
      when :failure               then request_failure_event
      else                             request_generic_event(name)
      end
    end
  end
end
