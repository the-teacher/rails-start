require_relative "../prompts/support_prompt"

# Bare-minimum agent — no lifecycle hooks, no streaming.
# Used for Case 1: simple request/response demo.
class SimpleAgent < ActiveHarness::Agent
  system_prompt SupportPrompt

  before(:call)      { @otel_span = AiTracer.start_span("agent.call", attributes: { "agent.class" => self.class.name }, parent_ctx: @context[:otel_ctx]) }

  after(:call) do |r|
    if @otel_span
      @otel_span.set_attribute("llm.model",  r.model.to_s)
      @otel_span.set_attribute("llm.time_s", r.execution_time.to_s)
      @otel_span.set_attribute("llm.tokens", r.usage&.dig("total_tokens").to_s)
      @otel_span.finish
      @otel_span = nil
    end
  end

  callback(:failure) do |_attempts|
    if @otel_span
      @otel_span.status = OpenTelemetry::Trace::Status.error("all_models_failed")
      @otel_span.finish
      @otel_span = nil
    end
  end

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
  end
end
