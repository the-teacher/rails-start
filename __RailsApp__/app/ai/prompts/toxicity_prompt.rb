class ToxicityPrompt
  def call
    <<~PROMPT.strip
      You are a toxicity classifier.
      Analyze the user message and reply ONLY with valid JSON, no markdown:
      {"toxic": true, "reason": "..."} if the message contains toxic content,
      {"toxic": false, "reason": "..."} if the message is safe.

      Toxic content includes: hate speech, slurs, threats, severe insults, or dehumanizing language.
    PROMPT
  end
end
