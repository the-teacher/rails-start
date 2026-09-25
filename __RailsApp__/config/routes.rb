Rails.application.routes.draw do
  # ── ActiveHarness demo cases ──────────────────────────────────────────────
  namespace :ai do
    # Cases index — entry point from home page
    get "cases", to: "cases#index", as: :cases

    # Request examples
    scope :requests, as: :requests do
      # Case 1 — simple request/response
      get  "simple",       to: "requests#simple",       as: :simple
      post "simple/call",  to: "requests#simple_call",  as: :simple_call

      # Case 2 — streaming, no lifecycle sidebar
      get "streaming",        to: "requests#streaming",        as: :streaming
      get "streaming/stream", to: "requests#streaming_stream", as: :streaming_stream

      # Case 3 — streaming + lifecycle sidebar
      get "lifecycle",        to: "requests#lifecycle",        as: :lifecycle
      get "lifecycle/stream", to: "requests#lifecycle_stream", as: :lifecycle_stream

      # Case 4 — ruby_llm backend + streaming + lifecycle sidebar
      get "ruby_llm",        to: "requests#ruby_llm",        as: :ruby_llm
      get "ruby_llm/stream", to: "requests#ruby_llm_stream", as: :ruby_llm_stream

      # Case 5 — fallback chain: 2 broken models prepended, watch retries in sidebar
      get "fallback",        to: "requests#fallback",        as: :fallback
      get "fallback/stream", to: "requests#fallback_stream", as: :fallback_stream

      # Case 6 — memory request: conversation history persisted via JsonFile
      get  "memory",        to: "requests#memory",        as: :memory
      post "memory/call",   to: "requests#memory_call",   as: :memory_call
      post "memory/clear",  to: "requests#memory_clear",  as: :memory_clear

      # Case 7 — image generation: OpenAI Images API (dall-e-2, 256x256)
      get  "image",      to: "requests#image",      as: :image
      post "image/call", to: "requests#image_call", as: :image_call

      # Case 8 — audio transcription: upload a file, get back the transcript text
      get  "transcribe",      to: "requests#transcribe",      as: :transcribe
      post "transcribe/call", to: "requests#transcribe_call", as: :transcribe_call

      # Case 9 — Jev (TypeSafe AI) via Vercel AI Gateway: evaluation, not chat
      get  "jev",      to: "requests#jev",      as: :jev
      post "jev/call", to: "requests#jev_call", as: :jev_call
    end

    # Prices — per-source pricing pages
    scope :prices, as: :prices do
      get "modelsdev",  to: "prices#modelsdev",  as: :modelsdev
      get "openrouter", to: "prices#openrouter", as: :openrouter
    end

    # Tribunal examples
    scope :tribunals, as: :tribunals do
      # Tribunal 1 — politeness: 1 request × 3 models, parallel verdict
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

      # Pipeline 3 — OpenAI Pricing: scrape page → extract structured JSON
      get  "openai_pricing",        to: "pipelines#openai_pricing",        as: :openai_pricing
      get  "openai_pricing/cached", to: "pipelines#openai_pricing_cached", as: :openai_pricing_cached
      post "openai_pricing/run",    to: "pipelines#openai_pricing_run",    as: :openai_pricing_run
    end
  end

  # Legacy endpoints kept for backward compatibility
  get  "ai/support",      to: "ai_support#index",        as: :ai_support
  post "ai/agent",          to: "ai_support#agent" # NOT renamed — see comment on AiSupportController#agent
  post "ai/request_memory", to: "ai_support#request_memory"
  post "ai/tribunal",       to: "ai_support#tribunal"
  post "ai/pipeline",       to: "ai_support#pipeline"
  get  "ai/request_stream", to: "ai_support#request_stream"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end

