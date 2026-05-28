# Single agent, three instances with different models are built by the tribunal.
class PolitenessAgent < ActiveHarness::Agent
  include AgentTracing
  
  system_prompt PolitenessPrompt
  
  format :json

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end

  before(:call) do
    @event_stream&.call(:llm_request, self.class.name)
  end

  after(:call) do |result|
    @event_stream&.call(:llm_response, result)
  end

  callback(:retry) do |entry, error|
    @event_stream&.call(:llm_retry, entry[:model], error)
  end
end
