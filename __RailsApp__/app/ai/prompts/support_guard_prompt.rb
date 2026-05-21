class SupportGuardPrompt
  def call
    <<~PROMPT.strip
      You are a spam detection filter.
      Analyze the message and reply ONLY with valid JSON, no markdown:
      {"spam": true, "reason": "..."} or {"spam": false, "reason": "..."}
    PROMPT
  end
end
