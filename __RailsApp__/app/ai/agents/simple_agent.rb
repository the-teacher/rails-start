# Bare-minimum agent — no lifecycle hooks, no streaming.
# Used for Case 1: simple request/response demo.
class SimpleAgent < ActiveHarness::Agent
  include AgentTracing

  system_prompt SupportPrompt

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
  end
end
