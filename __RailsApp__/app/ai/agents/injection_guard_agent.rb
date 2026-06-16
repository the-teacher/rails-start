class InjectionGuardAgent < ActiveHarness::Agent
  include AgentTracing

  system_prompt InjectionGuardPrompt
  format :json

  def tracing_extra_params(result)
    { "guard.detected" => result.processed&.dig("detected").to_s }
  end

  model do
    use      provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end

  before(:call) do
    Rails.logger.info "[InjectionGuard] ▶ calling…"
  end

  after(:call) do |result|
    Rails.logger.info "[InjectionGuard] ✓ done (#{result.execution_time}s) — detected: #{result.processed&.dig('detected')}"
  end

  callback(:retry) do |entry, error|
    Rails.logger.warn "[InjectionGuard] ↺ retry #{entry&.dig(:model)} — #{error&.message}"
  end

  callback(:failure) do
    Rails.logger.error "[InjectionGuard] ✗ all models failed"
  end
end
