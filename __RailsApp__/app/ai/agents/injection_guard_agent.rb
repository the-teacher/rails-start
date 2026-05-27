require_relative "../prompts/injection_guard_prompt"

class InjectionGuardAgent < ActiveHarness::Agent
  system_prompt InjectionGuardPrompt
  format :json

  before(:call)      { Rails.logger.info  "[InjectionGuard] ▶ calling…" }
  after(:call)       { |r| Rails.logger.info  "[InjectionGuard] ✓ done (#{r.execution_time}s) — detected: #{r.parsed&.dig('detected')}" }
  callback(:retry)   { |entry, err| Rails.logger.warn  "[InjectionGuard] ↺ retry #{entry&.dig(:model)} — #{err&.message}" }
  callback(:failure) { Rails.logger.error "[InjectionGuard] ✗ all models failed" }

  model do
    use      provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end
end
