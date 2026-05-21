require_relative "../prompts/support_prompt"

class SupportAgent < ActiveHarness::Agent
  system_prompt SupportPrompt

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
  end
end
