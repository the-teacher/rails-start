require_relative "../prompts/support_prompt"

# Case 4 — ruby_llm backend agent.
#
# HTTP calls are delegated to the ruby_llm gem instead of ActiveHarness's
# built-in Net::HTTP providers. The interface is identical to any other
# ActiveHarness agent — streaming, lifecycle hooks, fallback chain all work.
class SupportRubyLLMAgent < ActiveHarness::Agent
  system_prompt SupportPrompt

  model do
    use      provider: :openrouter, model: "mistralai/mistral-nemo",                  temperature: 0.5
    fallback provider: :openrouter, model: "meta-llama/llama-3.1-8b-instruct"
    fallback provider: :openrouter, model: "meta-llama/llama-3.3-70b-instruct:free"
  end

  # The block receives BackendParams with fields: model, provider, temperature.
  # It must return a RubyLLM::Chat instance.
  # assume_model_exists: true is required for models not in the RubyLLM registry.
  ruby_llm_backend do |params|
    RubyLLM.chat(
      model:               params.model,
      provider:            params.provider,
      assume_model_exists: true
    ).tap { |chat| chat.with_temperature(params.temperature) if params.temperature }
  end

  # Lifecycle hooks — publish events via @event_stream set on the instance.
  on(:setup)             { @event_stream&.call(:setup) }
  before(:system_prompt) { @event_stream&.call(:before_system_prompt) }
  after(:system_prompt)  { @event_stream&.call(:after_system_prompt) }
  before(:call)          { @event_stream&.call(:before_call) }
  after(:call)           { |r| @event_stream&.call(:after_call, r) }
  callback(:retry)       { |entry, err| @event_stream&.call(:retry, entry, err) }
  callback(:failure)     { |attempts| @event_stream&.call(:failure, attempts) }
end
