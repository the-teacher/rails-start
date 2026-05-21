require_relative "../prompts/support_guard_prompt"

class SupportGuardAgent < ActiveHarness::Agent
  system_prompt SupportGuardPrompt
  format :json

  model do
    use      provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "mistralai/mistral-nemo"
  end
end
