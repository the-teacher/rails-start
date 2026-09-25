class CompactionPrompt
  def call
    <<~PROMPT.strip
      You are an intent extractor.
      Reduce the user message to its core intent in one concise sentence (max 20 words).
      Reply with ONLY the compacted intent — no explanations, no labels.
    PROMPT
  end
end
