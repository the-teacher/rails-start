require_relative "../prompts/support_prompt"

class SupportAgent < ActiveHarness::Agent
  system_prompt SupportPrompt

  # Lifecycle hooks — publish events via @event_stream set on the instance.
  on(:setup)             { @event_stream&.call(:setup) }
  before(:system_prompt) { @event_stream&.call(:before_system_prompt) }
  after(:system_prompt)  { @event_stream&.call(:after_system_prompt) }
  before(:call)          { @event_stream&.call(:before_call) }
  after(:call)           { |r| @event_stream&.call(:after_call, r) }
  callback(:retry)       { |entry, err| @event_stream&.call(:retry, entry, err) }
  callback(:failure)     { |attempts| @event_stream&.call(:failure, attempts) }

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo"
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
  end
end
