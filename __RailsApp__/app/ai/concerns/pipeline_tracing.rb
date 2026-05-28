module PipelineTracing
  def self.included(base)
    base.before(:step) do |step_name, _payload|
      @otel_spans ||= {}

      unless @otel_pipeline_span
        @otel_pipeline_span = AiTracer.start_span("pipeline", attributes: {
          "pipeline.class" => self.class.name
        })
        @otel_pipeline_ctx = AiTracer.span_context(@otel_pipeline_span)
      end

      step_span = AiTracer.start_span("pipeline.step", attributes: {
        "pipeline.class" => self.class.name,
        "step.name"      => step_name.to_s
      }, parent_ctx: @otel_pipeline_ctx)
      @otel_spans[step_name] = step_span

      @params[:otel_ctx] = AiTracer.span_context(step_span)
    end

    base.after(:step) do |step_name, result|
      if (span = @otel_spans&.delete(step_name))
        span.set_attribute("llm.time_s", result.execution_time.to_s) if result.respond_to?(:execution_time)
        span.set_attribute("llm.model",  result.model.to_s)          if result.respond_to?(:model)
        span.finish
      end
    end

    base.callback(:stopped) do |step_name, result|
      if (span = @otel_spans&.delete(step_name))
        span.set_attribute("pipeline.stopped", "true")
        span.finish
      end
      if @otel_pipeline_span
        @otel_pipeline_span.set_attribute("pipeline.stopped_at", step_name.to_s)
        @otel_pipeline_span.finish
        @otel_pipeline_span = nil
      end
    end

    base.callback(:complete) do |_last_result|
      if @otel_pipeline_span
        @otel_pipeline_span.set_attribute("pipeline.time_s", execution_time.to_s)
        @otel_pipeline_span.finish
        @otel_pipeline_span = nil
      end
    end
  end
end
