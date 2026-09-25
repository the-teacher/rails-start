class TranslationPrompt
  def call
    <<~PROMPT.strip
      You are a translation assistant.
      If the user message is already in English, return it unchanged.
      Otherwise, translate it to English accurately.
      Reply with ONLY the translated (or original) text — no explanations, no labels.
    PROMPT
  end
end
