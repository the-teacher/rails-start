require_relative "../prompts/relevance_prompt"

class RelevanceAgent < ActiveHarness::Agent
  system_prompt RelevancePrompt
  format :json

  before(:call)      { Rails.logger.info  "[Relevance] ▶ calling…" }
  after(:call)       { |r| Rails.logger.info  "[Relevance] ✓ done (#{r.execution_time}s) — relevant: #{r.parsed&.dig('relevant')}" }
  callback(:retry)   { |entry, err| Rails.logger.warn  "[Relevance] ↺ retry #{entry&.dig(:model)} — #{err&.message}" }
  callback(:failure) { Rails.logger.error "[Relevance] ✗ all models failed" }

  model do
    use      provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end
end
