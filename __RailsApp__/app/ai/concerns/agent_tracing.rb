module AgentTracing
  def self.included(base)
    base.before(:call) do
      @tracer_span = AiTracer.start_span(tracing_span_name,
        attributes: { "agent.class" => self.class.name },
        parent_ctx: @params[:tracer_ctx]
      )
      @tracer_span.event("before_call")
    end

    base.after(:call) do |result|
      if @tracer_span
        @tracer_span
          .event("after_call",
            llm: { model: result.model, time_s: result.execution_time, tokens: result.usage&.dig("total_tokens") }
          )
          .attrs({
            "llm.model"  => result.model,
            "llm.time_s" => result.execution_time,
            "llm.tokens" => result.usage&.dig("total_tokens")
          })
          .attrs(tracing_extra_params(result))
          .finish
        @tracer_span = nil
      end
    end

    base.before(:system_prompt) do
      @tracer_span&.event("before_system_prompt")
    end

    base.after(:system_prompt) do |prompt|
      @tracer_span&.event("after_system_prompt",
        prompt: { chars: prompt.to_s.length }
      )
    end

    base.callback(:parse_error) do |_raw, error|
      @tracer_span&.event("parse_error",
        error: { class: error.class.name, message: error.message.to_s[0, 200] }
      )
    end

    base.callback(:retry) do |entry, error|
      @tracer_span&.event("retry",
        model: entry&.dig(:model),
        error: error&.message
      )
    end

    base.callback(:failure) do |_attempts|
      if @tracer_span
        @tracer_span.status = OpenTelemetry::Trace::Status.error("all_models_failed")
        @tracer_span.finish
        @tracer_span = nil
      end
    end
  end

  # Override to add domain-specific span attributes set before the span closes.
  #
  #   def tracing_extra_params(result)
  #     { "guard.detected" => result.processed&.dig("detected") }
  #   end
  def tracing_extra_params(_result)
    {}
  end

  # Override to customise the Jaeger operation name for this agent.
  def tracing_span_name
    self.class.name
  end
end
