require_relative "../prompts/compaction_prompt"

class CompactionAgent < ActiveHarness::Agent
  system_prompt CompactionPrompt

  before(:call) do
    @otel_span = AiTracer.start_span("agent.call", attributes: { "agent.class" => self.class.name })
    Rails.logger.info "[Compaction] ▶ calling…"
  end

  after(:call) do |r|
    if @otel_span
      @otel_span.set_attribute("llm.model",  r.model.to_s)
      @otel_span.set_attribute("llm.time_s", r.execution_time.to_s)
      @otel_span.set_attribute("llm.tokens", r.usage&.dig("total_tokens").to_s)
      @otel_span.finish
      @otel_span = nil
    end
    Rails.logger.info "[Compaction] ✓ done (#{r.execution_time}s) — #{r.output.to_s.truncate(80)}"
  end

  callback(:retry) do |entry, err|
    @otel_span&.add_event("retry", attributes: { "model" => entry&.dig(:model).to_s, "error" => err&.message.to_s })
    Rails.logger.warn "[Compaction] ↺ retry #{entry&.dig(:model)} — #{err&.message}"
  end

  callback(:failure) do |_attempts|
    if @otel_span
      @otel_span.status = OpenTelemetry::Trace::Status.error("all_models_failed")
      @otel_span.finish
      @otel_span = nil
    end
    Rails.logger.error "[Compaction] ✗ all models failed"
  end

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end
end
