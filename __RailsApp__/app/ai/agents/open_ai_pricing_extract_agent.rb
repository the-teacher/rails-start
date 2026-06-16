class OpenAiPricingExtractAgent < ActiveHarness::Agent
  include AgentTracing

  system_prompt OpenAiPricingExtractPrompt
  format :json

  model do
    use      provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "anthropic/claude-haiku-4-5-20251001"
    fallback provider: :openrouter, model: "openai/gpt-4o-mini"
    fallback provider: :openrouter, model: "google/gemini-flash-1.5"
  end

  before(:call) do
    Rails.logger.info "[OpenAiPricingExtract] ▶ extracting pricing from #{@input&.length} chars…"
  end

  after(:call) do |result|
    count = result.processed&.dig("models")&.size || 0
    Rails.logger.info "[OpenAiPricingExtract] ✓ done (#{result.execution_time}s) — #{count} models extracted"
  end

  callback(:retry) do |entry, error|
    Rails.logger.warn "[OpenAiPricingExtract] ↺ retry #{entry&.dig(:model)} — #{error&.message}"
  end

  callback(:failure) do
    Rails.logger.error "[OpenAiPricingExtract] ✗ all models failed"
  end
end
