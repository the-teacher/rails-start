class MemoryPrompt
  BASE_INSTRUCTION    = "You are a helpful conversational assistant. " \
                        "Keep answers concise (1-3 sentences). "        \
                        "Remember context from the conversation."
  HISTORY_FRACTION    = 0.25

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
    @history_messages ||= begin
      if @context_window
        fraction = @params&.[](:history_fraction) || HISTORY_FRACTION
        budget   = (@context_window * fraction).to_i
        @memory&.to_messages(token_budget: budget) || []
      else
        @memory&.to_messages || []
      end
    end
  end

  def format_history(messages)
    messages.map { |m| m[:content] }.join("\n")
  end
end
