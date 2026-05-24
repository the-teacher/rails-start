# Pin npm packages by running ./bin/importmap

pin "application"
pin "ai_support"
pin "ai_agent_simple"
pin "ai_agent_streaming"
pin "ai_agent_lifecycle"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
