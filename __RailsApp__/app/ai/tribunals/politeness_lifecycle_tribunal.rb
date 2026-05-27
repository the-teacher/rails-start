require_relative "../agents/politeness_agent"
require_relative "politeness_tribunal"

# Same as PolitenessTribunal but wires lifecycle hooks to an event_stream,
# enabling a live sidebar in the browser (Case T-02).
class PolitenessLifecycleTribunal < ActiveHarness::Tribunal
  on(:before_agent) { |agent, index| @tribunal_event_stream&.call(:agent_start, index) }
  on(:after_agent)  { |result, index| @tribunal_event_stream&.call(:agent_done, result, index) }
  on(:agent_error)  { |name, err, index| @tribunal_event_stream&.call(:agent_error, name, err, index) }
  on(:after_call)   { |results, _errors| @tribunal_event_stream&.call(:all_done) }
  on(:after_verdict){ |verdict| @tribunal_event_stream&.call(:verdict, verdict) }

  def initialize(input:, streams: {})
    agents = PolitenessTribunal::MODELS.map do |model|
      PolitenessAgent.new(models: [{ provider: :openrouter, model: model }])
    end

    super(input: input, agents: agents, streams: streams)
  end

  verdict :majority, may_fail: 1 do |result|
    result.parsed["result"] == true
  end
end
