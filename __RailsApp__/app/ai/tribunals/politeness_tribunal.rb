# Runs the same PolitenessAgent with three different models in parallel.
# Verdict is true (polite) when all three agree.
class PolitenessTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  MODELS = [
    "mistralai/mistral-nemo",
    "meta-llama/llama-3.1-8b-instruct",
    "sao10k/l3-lunaris-8b"
  ].freeze

  def initialize(input:)
    agents = MODELS.map do |model|
      PolitenessAgent.new(models: [{ provider: :openrouter, model: model }])
    end

    super(input: input, agents: agents)
  end

  verdict :unanimous do |result|
    result.processed["result"] == true
  end
end
