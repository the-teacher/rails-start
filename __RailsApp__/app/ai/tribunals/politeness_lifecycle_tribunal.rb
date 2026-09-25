# Same as PolitenessTribunal but wires lifecycle hooks to an event_stream,
# enabling a live sidebar in the browser (Case T-02).
class PolitenessLifecycleTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  def initialize(input:, token: nil, stream: nil)
    requests = PolitenessTribunal::MODELS.map do |model|
      PolitenessRequest.new(models: [{ provider: :openrouter, model: model }])
    end

    super(input: input, requests: requests, token: token, stream: stream)
  end

  verdict :majority, may_fail: 1 do |result|
    result.processed["result"] == true
  end

  on(:before_request) do |request, index|
    @stream&.call(:tribunal, :request_start, index)
  end

  on(:after_request) do |result, index|
    @stream&.call(:tribunal, :request_done, result, index)
  end

  on(:request_error) do |name, error, index|
    @stream&.call(:tribunal, :request_error, name, error, index)
  end

  on(:after_call) do |results, _errors|
    @stream&.call(:tribunal, :all_done)
  end

  after(:verdict) do |verdict|
    @stream&.call(:tribunal, :verdict, verdict)
  end
end
