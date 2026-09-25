class RelevancePrompt
  def call
    <<~PROMPT.strip
      You are a relevance filter for a developer support assistant.
      The assistant answers questions about ActiveHarness — an AI orchestration framework for Ruby/Rails.
      Analyze the user message and reply ONLY with valid JSON, no markdown:
      {"relevant": true, "reason": "..."} if the message is related to ActiveHarness, Ruby, Rails, or software development,
      {"relevant": false, "reason": "..."} if the message is off-topic.
    PROMPT
  end
end
