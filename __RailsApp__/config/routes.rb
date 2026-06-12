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

      # Case 5 — fallback chain: 2 broken models prepended, watch retries in sidebar
      get "fallback",        to: "agents#fallback",        as: :fallback
      get "fallback/stream", to: "agents#fallback_stream", as: :fallback_stream

      # Case 6 — memory agent: conversation history persisted via JsonFile
      get  "memory",        to: "agents#memory",        as: :memory
      post "memory/call",   to: "agents#memory_call",   as: :memory_call
      post "memory/clear",  to: "agents#memory_clear",  as: :memory_clear
    end

    # Costs — model pricing reference
    get "costs", to: "costs#index", as: :costs

    # Tribunal examples
    scope :tribunals, as: :tribunals do
      # Tribunal 1 — politeness: 1 agent × 3 models, parallel verdict
      get  "politeness",      to: "tribunals#politeness",      as: :politeness
      post "politeness/call", to: "tribunals#politeness_call", as: :politeness_call

      # Tribunal 2 — politeness with live lifecycle event sidebar
      get "politeness/lifecycle",        to: "tribunals#politeness_lifecycle",        as: :politeness_lifecycle
      get "politeness/lifecycle/stream", to: "tribunals#politeness_lifecycle_stream", as: :politeness_lifecycle_stream
    end

    # Pipeline examples
    scope :pipelines, as: :pipelines do
      # Pipeline 1 — nested pipeline (laundry sub-pipeline) with live event log
      get "support",        to: "pipelines#support",        as: :support
      get "support/stream", to: "pipelines#support_stream", as: :support_stream

      # Pipeline 2 — flat pipeline (same 6 steps, no sub-pipeline nesting)
      get "flat",        to: "pipelines#flat",        as: :flat
      get "flat/stream", to: "pipelines#flat_stream", as: :flat_stream
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

