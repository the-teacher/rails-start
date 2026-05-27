require_relative "../prompts/support_prompt"

# Case 4 — ruby_llm backend agent.
#
# HTTP calls are delegated to the ruby_llm gem instead of ActiveHarness's
# built-in Net::HTTP providers. The interface is identical to any other
# ActiveHarness agent — streaming, lifecycle hooks, fallback chain all work.
class SupportRubyLLMAgent < ActiveHarness::Agent
  system_prompt SupportPrompt

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo",                  temperature: 0.5
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end

  # The block receives BackendParams with fields: model, provider, temperature.
  # It must return a RubyLLM::Chat instance.
  # assume_model_exists: true is required for models not in the RubyLLM registry.
  custom_llm_backend do |params|
    RubyLLM.chat(
      model:               params.model,
      provider:            params.provider,
      assume_model_exists: true
    ).tap { |chat| chat.with_temperature(params.temperature) if params.temperature }
  end

  # Lifecycle hooks — side-effects only; event_stream is auto-fired by Agent#fire.
  on(:setup) { Rails.logger.info "[SupportRubyLLM] setup" }

  before(:call) do
    @otel_span = AiTracer.start_span("agent.call", attributes: { "agent.class" => self.class.name })
    Rails.logger.info "[SupportRubyLLM] ▶ calling…"
  end

  after(:call) do |r|
    if @otel_span
      @otel_span.set_attribute("llm.model",  r.model.to_s)
      @otel_span.set_attribute("llm.time_s", r.execution_time.to_s)
      @otel_span.set_attribute("llm.tokens", r.usage&.dig("total_tokens").to_s)
      @otel_span.finish
      @otel_span = nil
    end
    Rails.logger.info "[SupportRubyLLM] ✓ done (#{r.execution_time}s)"
  end

  callback(:retry) do |entry, err|
    @otel_span&.add_event("retry", attributes: { "model" => entry&.dig(:model).to_s, "error" => err&.message.to_s })
    Rails.logger.warn "[SupportRubyLLM] ↺ retry #{entry&.dig(:model)} — #{err&.message}"
  end

  callback(:failure) do |_attempts|
    if @otel_span
      @otel_span.status = OpenTelemetry::Trace::Status.error("all_models_failed")
      @otel_span.finish
      @otel_span = nil
    end
    Rails.logger.error "[SupportRubyLLM] ✗ all models failed"
  end
end
