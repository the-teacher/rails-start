require_relative "../prompts/politeness_prompt"

# Single agent, three instances with different models are built by the tribunal.
class PolitenessAgent < ActiveHarness::Agent
  system_prompt PolitenessPrompt
  format :json

  model do
    use provider: :openrouter, model: "mistralai/mistral-nemo"
  end

  on(:before_call) { @event_stream&.call(:llm_request, self.class.name) }
  on(:after_call)  { |result| @event_stream&.call(:llm_response, result) }
  on(:retry)       { |entry, err| @event_stream&.call(:llm_retry, entry[:model], err) }
end
