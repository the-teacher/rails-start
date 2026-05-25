require_relative "../agents/politeness_agent"
require_relative "politeness_tribunal"

# Same as PolitenessTribunal but wires lifecycle hooks to an event_stream,
# enabling a live sidebar in the browser (Case T-02).
class PolitenessLifecycleTribunal < ActiveHarness::Tribunal
  on(:before_agent) { |agent, index| @event_stream&.call(:agent_start, index) }
  on(:after_agent)  { |result, index| @event_stream&.call(:agent_done, result, index) }
  on(:agent_error)  { |name, err, index| @event_stream&.call(:agent_error, name, err, index) }
  on(:after_call)   { |results, _errors| @event_stream&.call(:all_done) }
  on(:after_verdict){ |verdict| @event_stream&.call(:verdict, verdict) }

  def initialize(input:, event_stream: nil)
    agents = PolitenessTribunal::MODELS.map do |model|
      PolitenessAgent.new(models: [{ provider: :openrouter, model: model }])
    end

    super(input: input, agents: agents, event_stream: event_stream)
  end

  process do |results|
    results.all? { |r| r.parsed["result"] == true }
  end
end
