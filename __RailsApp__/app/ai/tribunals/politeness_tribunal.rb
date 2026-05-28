require_relative "../agents/politeness_agent"

# Runs the same PolitenessAgent with three different models in parallel.
# Verdict is true (polite) when all three agree.
class PolitenessTribunal < ActiveHarness::Tribunal
  on(:before_call)   { @otel_span = AiTracer.start_span("tribunal.call", attributes: { "tribunal.class" => self.class.name }, parent_ctx: @context[:otel_ctx]) }

  on(:after_verdict) do |verdict|
    if @otel_span
      @otel_span.set_attribute("tribunal.verdict", verdict.to_s)
      @otel_span.set_attribute("tribunal.time_s",  execution_time.to_s)
      @otel_span.finish
      @otel_span = nil
    end
  end

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
    result.parsed["result"] == true
  end
end
