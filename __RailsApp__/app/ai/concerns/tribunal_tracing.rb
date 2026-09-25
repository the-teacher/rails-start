module TribunalTracing
  def self.included(base)
    base.on(:before_call) do
      @tracer_span = AiTracer.start_span(tracing_span_name,
        attributes: { "tribunal.class" => self.class.name },
        parent_ctx: @params[:tracer_ctx]
      )
      # Propagate tribunal span as parent for all requests running inside this tribunal.
      # @params is shared by reference with all requests instantiated in resolve_requests,
      # so updating it here (before futures start) makes request spans children of the tribunal.
      @params[:tracer_ctx] = AiTracer.span_context(@tracer_span)
    end

    base.on(:after_request) do |result, index|
      @tracer_span&.event("request_done",
        request: { index: index },
        llm: { model: result.model&.name, time_s: result.execution_time }
      )
    end

    base.on(:request_error) do |name, error, _index|
      @tracer_span&.event("request_error",
        request: { class: name },
        error: error&.message
      )
    end

    base.on(:after_verdict) do |verdict|
      if @tracer_span
        @tracer_span
          .attrs({
            "tribunal.verdict" => verdict.to_s,
            "tribunal.time_s"  => execution_time.to_s
          })
          .finish
        @tracer_span = nil
      end
    end
  end

  # Override to customise the Jaeger operation name for this tribunal.
  def tracing_span_name
    self.class.name
  end
end
