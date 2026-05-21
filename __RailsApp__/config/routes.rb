Rails.application.routes.draw do
  # ActiveHarness — AI support endpoints
  post "ai/agent",        to: "ai_support#agent"
  post "ai/agent_memory", to: "ai_support#agent_memory"
  post "ai/tribunal",     to: "ai_support#tribunal"
  post "ai/pipeline",     to: "ai_support#pipeline"
  get  "ai/agent_stream", to: "ai_support#agent_stream"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
