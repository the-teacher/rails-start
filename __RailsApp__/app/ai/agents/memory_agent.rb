class MemoryAgent < ActiveHarness::Agent
  include AgentMemory
  include AgentTracing

  system_prompt MemoryPrompt

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
  end
end
