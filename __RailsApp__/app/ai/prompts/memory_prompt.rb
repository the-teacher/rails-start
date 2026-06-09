class MemoryPrompt
  BASE_INSTRUCTION = "You are a helpful conversational assistant. " \
                     "Keep answers concise (1-3 sentences). "        \
                     "Remember context from the conversation."

  def call
    return BASE_INSTRUCTION if history_messages.empty?

    <<~PROMPT
      #{BASE_INSTRUCTION}

      Conversation so far:
      #{format_history(history_messages)}
    PROMPT
  end

  private

  def history_messages
    @history_messages ||= @context&.[](:memory)&.to_messages || []
  end

  def format_history(messages)
    messages.map do |message|
      message[:content]
    end.join("\n")
  end
end
