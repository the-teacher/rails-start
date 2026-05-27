require_relative "../prompts/politeness_prompt"

# Single agent, three instances with different models are built by the tribunal.
class PolitenessAgent < ActiveHarness::Agent
  system_prompt PolitenessPrompt
  format :json

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "sao10k/l3-lunaris-8b"
    fallback provider: :openrouter, model: "google/gemma-3-4b-it"
    fallback provider: :openrouter, model: "mistralai/mistral-small-24b-instruct-2501"
    fallback provider: :openrouter, model: "gryphe/mythomax-l2-13b"
  end

  on(:before_call) { @event_stream&.call(:llm_request, self.class.name) }
  on(:after_call)  { |result| @event_stream&.call(:llm_response, result) }
  on(:retry)       { |entry, err| @event_stream&.call(:llm_retry, entry[:model], err) }
end
