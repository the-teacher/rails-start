require_relative "../prompts/politeness_prompt"

# Single agent, three instances with different models are built by the tribunal.
class PolitenessAgent < ActiveHarness::Agent
  system_prompt PolitenessPrompt
  format :json

  model do
    use provider: :openrouter, model: "mistralai/mistral-nemo"
  end
end
