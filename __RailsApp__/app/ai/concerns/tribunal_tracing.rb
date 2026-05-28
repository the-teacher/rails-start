module TribunalTracing
  def self.included(base)
    base.on(:before_call) do
      @otel_span = AiTracer.start_span("tribunal.call",
        attributes: { "tribunal.class" => self.class.name },
        parent_ctx: @params[:otel_ctx]
      )
    end

    base.on(:after_agent) do |result, index|
      @otel_span&.add_event("agent_done", attributes: {
        "agent.index" => index.to_s,
        "llm.model"   => result.model.to_s,
        "llm.time_s"  => result.execution_time.to_s
      })
    end

    base.on(:agent_error) do |name, error, _index|
      @otel_span&.add_event("agent_error", attributes: {
        "agent.class" => name.to_s,
        "error"       => error&.message.to_s
      })
    end

    base.on(:after_verdict) do |verdict|
      if @otel_span
        @otel_span.set_attribute("tribunal.verdict", verdict.to_s)
        @otel_span.set_attribute("tribunal.time_s",  execution_time.to_s)
        @otel_span.finish
        @otel_span = nil
      end
    end
  end
end
