module AgentTracing
  def self.included(base)
    base.before(:call) do
      @otel_span = AiTracer.start_span("agent.call",
        attributes: { "agent.class" => self.class.name },
        parent_ctx: @params[:otel_ctx]
      )
    end

    base.after(:call) do |result|
      if @otel_span
        @otel_span.set_attribute("llm.model",  result.model.to_s)
        @otel_span.set_attribute("llm.time_s", result.execution_time.to_s)
        @otel_span.set_attribute("llm.tokens", result.usage&.dig("total_tokens").to_s)
        tracing_extra_params(result).each { |k, v| @otel_span.set_attribute(k, v.to_s) }
        @otel_span.finish
        @otel_span = nil
      end
    end

    base.callback(:retry) do |entry, error|
      @otel_span&.add_event("retry", attributes: {
        "model" => entry&.dig(:model).to_s,
        "error" => error&.message.to_s
      })
    end

    base.callback(:failure) do |_attempts|
      if @otel_span
        @otel_span.status = OpenTelemetry::Trace::Status.error("all_models_failed")
        @otel_span.finish
        @otel_span = nil
      end
    end
  end

  # Override to add domain-specific span attributes set before the span closes.
  #
  #   def tracing_extra_params(result)
  #     { "guard.detected" => result.parsed&.dig("detected").to_s }
  #   end
  def tracing_extra_params(_result)
    {}
  end
end
