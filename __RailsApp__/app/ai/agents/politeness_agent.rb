require_relative "../prompts/politeness_prompt"

# Single agent, three instances with different models are built by the tribunal.
class PolitenessAgent < ActiveHarness::Agent
  system_prompt PolitenessPrompt
  format :json

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end

  on(:before_call) do
    @otel_span = AiTracer.start_span("agent.call", attributes: { "agent.class" => self.class.name })
    @event_stream&.call(:llm_request, self.class.name)
  end

  on(:after_call) do |result|
    if @otel_span
      @otel_span.set_attribute("llm.model",  result.model.to_s)
      @otel_span.set_attribute("llm.time_s", result.execution_time.to_s)
      @otel_span.finish
      @otel_span = nil
    end
    @event_stream&.call(:llm_response, result)
  end

  on(:retry) do |entry, err|
    @otel_span&.add_event("retry", attributes: { "model" => entry[:model].to_s, "error" => err&.message.to_s })
    @event_stream&.call(:llm_retry, entry[:model], err)
  end
end
