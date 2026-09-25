# Runs the same PolitenessRequest with three different models in parallel.
# Verdict is true (polite) when all three agree.
class PolitenessTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  MODELS = [
    "mistralai/mistral-nemo",
    "meta-llama/llama-3.1-8b-instruct",
    "sao10k/l3-lunaris-8b"
  ].freeze

  def initialize(input:)
    requests = MODELS.map do |model|
      PolitenessRequest.new(models: [{ provider: :openrouter, model: model }])
    end

    super(input: input, requests: requests)
  end

  verdict :unanimous do |result|
    result.processed["result"] == true
  end
end
