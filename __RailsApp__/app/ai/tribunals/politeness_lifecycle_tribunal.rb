# Same as PolitenessTribunal but wires lifecycle hooks to an event_stream,
# enabling a live sidebar in the browser (Case T-02).
class PolitenessLifecycleTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  def initialize(input:, streams: {})
    agents = PolitenessTribunal::MODELS.map do |model|
      PolitenessAgent.new(models: [{ provider: :openrouter, model: model }])
    end

    super(input: input, agents: agents, streams: streams)
  end

  verdict :majority, may_fail: 1 do |result|
    result.processed["result"] == true
  end

  on(:before_agent) do |agent, index|
    @tribunal_event_stream&.call(:agent_start, index)
  end

  on(:after_agent) do |result, index|
    @tribunal_event_stream&.call(:agent_done, result, index)
  end

  on(:agent_error) do |name, error, index|
    @tribunal_event_stream&.call(:agent_error, name, error, index)
  end

  on(:after_call) do |results, _errors|
    @tribunal_event_stream&.call(:all_done)
  end

  after(:verdict) do |verdict|
    @tribunal_event_stream&.call(:verdict, verdict)
  end
end
