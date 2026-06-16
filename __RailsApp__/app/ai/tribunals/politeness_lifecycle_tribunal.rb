# Same as PolitenessTribunal but wires lifecycle hooks to an event_stream,
# enabling a live sidebar in the browser (Case T-02).
class PolitenessLifecycleTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  def initialize(input:, token: nil, stream: nil)
    agents = PolitenessTribunal::MODELS.map do |model|
      PolitenessAgent.new(models: [{ provider: :openrouter, model: model }])
    end

    super(input: input, agents: agents, token: token, stream: stream)
  end

  verdict :majority, may_fail: 1 do |result|
    result.processed["result"] == true
  end

  on(:before_agent) do |agent, index|
    @stream&.call(:tribunal, :agent_start, index)
  end

  on(:after_agent) do |result, index|
    @stream&.call(:tribunal, :agent_done, result, index)
  end

  on(:agent_error) do |name, error, index|
    @stream&.call(:tribunal, :agent_error, name, error, index)
  end

  on(:after_call) do |results, _errors|
    @stream&.call(:tribunal, :all_done)
  end

  after(:verdict) do |verdict|
    @stream&.call(:tribunal, :verdict, verdict)
  end
end
