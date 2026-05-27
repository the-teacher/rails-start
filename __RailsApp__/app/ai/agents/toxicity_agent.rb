require_relative "../prompts/toxicity_prompt"

class ToxicityAgent < ActiveHarness::Agent
  system_prompt ToxicityPrompt
  format :json

  before(:call)      { Rails.logger.info  "[Toxicity] ▶ calling…" }
  after(:call)       { |r| Rails.logger.info  "[Toxicity] ✓ done (#{r.execution_time}s) — toxic: #{r.parsed&.dig('toxic')}" }
  callback(:retry)   { |entry, err| Rails.logger.warn  "[Toxicity] ↺ retry #{entry&.dig(:model)} — #{err&.message}" }
  callback(:failure) { Rails.logger.error "[Toxicity] ✗ all models failed" }

  model do
    use      provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end
end
