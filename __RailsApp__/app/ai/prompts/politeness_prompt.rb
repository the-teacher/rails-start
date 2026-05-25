class PolitenessPrompt
  def call
    <<~PROMPT.strip
      You are a politeness evaluator.
      Analyze the following message and decide whether it is polite.
      Reply ONLY with valid JSON, no markdown:
      {"result": true, "reason": "..."}
      Use true if polite, false if not.
    PROMPT
  end
end
