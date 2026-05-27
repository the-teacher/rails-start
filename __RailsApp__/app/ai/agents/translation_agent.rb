require_relative "../prompts/translation_prompt"

class TranslationAgent < ActiveHarness::Agent
  system_prompt TranslationPrompt

  before(:call)      { Rails.logger.info  "[Translation] ▶ calling…" }
  after(:call)       { |r| Rails.logger.info  "[Translation] ✓ done (#{r.execution_time}s) — #{r.output.to_s.truncate(80)}" }
  callback(:retry)   { |entry, err| Rails.logger.warn  "[Translation] ↺ retry #{entry&.dig(:model)} — #{err&.message}" }
  callback(:failure) { Rails.logger.error "[Translation] ✗ all models failed" }

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end
end
