module ApplicationHelper
  # Rough conversion: 1 A4 page ≈ 500 tokens (plain text, normal font size).
  TOKENS_PER_A4_PAGE = 500

  def context_to_a4(tokens)
    return nil unless tokens
    pages = (tokens / TOKENS_PER_A4_PAGE.to_f).round
    pages > 0 ? pages : 1
  end
end
