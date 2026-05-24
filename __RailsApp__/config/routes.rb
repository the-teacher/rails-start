Rails.application.routes.draw do
  # ── ActiveHarness demo cases ──────────────────────────────────────────────
  namespace :ai do
    # Cases index — entry point from home page
    get "cases", to: "cases#index", as: :cases

    # Agent examples
    scope :agents, as: :agents do
      # Case 1 — simple request/response
      get  "simple",       to: "agents#simple",       as: :simple
      post "simple/call",  to: "agents#simple_call",  as: :simple_call

      # Case 2 — streaming, no lifecycle sidebar
      get "streaming",        to: "agents#streaming",        as: :streaming
      get "streaming/stream", to: "agents#streaming_stream", as: :streaming_stream

      # Case 3 — streaming + lifecycle sidebar
      get "lifecycle",        to: "agents#lifecycle",        as: :lifecycle
      get "lifecycle/stream", to: "agents#lifecycle_stream", as: :lifecycle_stream

      # Case 4 — ruby_llm backend + streaming + lifecycle sidebar
      get "ruby_llm",        to: "agents#ruby_llm",        as: :ruby_llm
      get "ruby_llm/stream", to: "agents#ruby_llm_stream", as: :ruby_llm_stream
    end
  end

  # Legacy endpoints kept for backward compatibility
  get  "ai/support",      to: "ai_support#index",        as: :ai_support
  post "ai/agent",        to: "ai_support#agent"
  post "ai/agent_memory", to: "ai_support#agent_memory"
  post "ai/tribunal",     to: "ai_support#tribunal"
  post "ai/pipeline",     to: "ai_support#pipeline"
  get  "ai/agent_stream", to: "ai_support#agent_stream"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end

