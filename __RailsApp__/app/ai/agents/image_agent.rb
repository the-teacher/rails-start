class ImageAgent < ActiveHarness::Agent
  image true
  size  "1024x1024"

  model do
    use      provider: :openrouter, model: "openai/gpt-5-image-mini"
    fallback provider: :openrouter, model: "google/gemini-2.5-flash-image"
  end

  # result.output — "data:image/png;base64,..." or HTTPS URL (OpenRouter)
end
