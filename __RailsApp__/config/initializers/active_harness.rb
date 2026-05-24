# config/initializers/active_harness.rb

ActiveHarness.configure do |config|
  config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
  # config.openrouter_http_referer = "https://your-app.com"
end

# Configure ruby_llm gem (used by SupportRubyLLMAgent — Case 4).
RubyLLM.configure do |c|
  c.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
end
