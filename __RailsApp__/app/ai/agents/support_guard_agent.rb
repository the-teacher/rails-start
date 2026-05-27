require_relative "../prompts/support_guard_prompt"

class SupportGuardAgent < ActiveHarness::Agent
  system_prompt SupportGuardPrompt
  format :json

  before(:call) do
    @otel_span = AiTracer.start_span("agent.call", attributes: { "agent.class" => self.class.name })
  end

  after(:call) do |r|
    if @otel_span
      @otel_span.set_attribute("llm.model",   r.model.to_s)
      @otel_span.set_attribute("llm.time_s",  r.execution_time.to_s)
      @otel_span.set_attribute("guard.spam",  r.parsed&.dig("spam").to_s)
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
    use      provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end
end
