require_relative "../prompts/support_prompt"

class SupportAgent < ActiveHarness::Agent
  system_prompt SupportPrompt

  before(:call)      { Rails.logger.info  "[Support] ▶ calling…" }
  after(:call)       { |r| Rails.logger.info  "[Support] ✓ done (#{r.execution_time}s)" }
  callback(:retry)   { |entry, err| Rails.logger.warn  "[Support] ↺ retry #{entry&.dig(:model)} — #{err&.message}" }
  callback(:failure) { |attempts| Rails.logger.error "[Support] ✗ all models failed" }

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end
end
