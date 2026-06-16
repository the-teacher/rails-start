class SupportAgent < ActiveHarness::Agent
  include AgentTracing

  system_prompt SupportPrompt

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end

  before(:call) do
    Rails.logger.info "[Support] ▶ calling…"
  end

  after(:call) do |result|
    Rails.logger.info "[Support] ✓ done (#{result.execution_time}s)"
  end

  callback(:retry) do |entry, error|
    Rails.logger.warn "[Support] ↺ retry #{entry&.dig(:model)} — #{error&.message}"
  end

  callback(:failure) do
    Rails.logger.error "[Support] ✗ all models failed"
  end
end
