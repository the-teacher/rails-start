# Bare-minimum request — no lifecycle hooks, no streaming.
# Used for Case 1: simple request/response demo.
class SimpleRequest < ActiveHarness::Request
  include RequestTracing

  system_prompt SupportPrompt

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
  end
end
