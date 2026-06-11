module PipelineTracing
  def self.included(base)
    base.before(:step) do |step_name, _payload|
      @tracer_spans ||= {}

      unless @tracer_span_pipeline
        @tracer_span_pipeline = AiTracer.start_span(tracing_span_name,
          attributes: { "pipeline.class" => self.class.name },
          parent_ctx: @params[:tracer_ctx]
        )
        @tracer_ctx_pipeline = AiTracer.span_context(@tracer_span_pipeline)
      end

      step_span = AiTracer.start_span(step_name.to_s, attributes: {
        "pipeline.class" => self.class.name,
        "step.name"      => step_name.to_s
      }, parent_ctx: @tracer_ctx_pipeline)
      @tracer_spans[step_name] = step_span

      @params[:tracer_ctx] = AiTracer.span_context(step_span)
    end

    base.after(:step) do |step_name, result|
      if (span = @tracer_spans&.delete(step_name))
        attrs = {}
        attrs["llm.time_s"] = result.execution_time if result.respond_to?(:execution_time)
        attrs["llm.model"]  = result.model          if result.respond_to?(:model)
        span.attrs(attrs).finish unless attrs.empty?
        span.finish if attrs.empty?
      end
    end

    base.callback(:stopped) do |step_name, _result|
      if (span = @tracer_spans&.delete(step_name))
        span.attrs({ "pipeline.stopped" => true }).finish
      end
      if @tracer_span_pipeline
        @tracer_span_pipeline
          .attrs({ "pipeline.stopped_at" => step_name.to_s })
          .finish
        @tracer_span_pipeline = nil
      end
    end

    base.callback(:complete) do |_last_result|
      if @tracer_span_pipeline
        @tracer_span_pipeline
          .attrs({ "pipeline.time_s" => execution_time })
          .finish
        @tracer_span_pipeline = nil
      end
    end
  end

  # Override to customise the Jaeger operation name for this pipeline.
  def tracing_span_name
    self.class.name
  end
end
