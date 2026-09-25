class JevRequest < ActiveHarness::Request
  format :json

  # Three questions of three different types in one call, to show the full
  # shape of a Jev answer (noul/score/choice each answer differently) rather
  # than just a single probability.
  QUESTIONS = {
    sentiment: {
      type:         "score",
      instructions: "How positive is the tone of this message?",
      criteria:     ["very negative", "negative", "neutral", "positive", "very positive"]
    },
    topic: {
      type:         "choice",
      instructions: "What is this message mainly about?",
      criteria: {
        support:  "asking for help or reporting a problem",
        feedback: "sharing an opinion, praise, or complaint",
        spam:     "promotional or unrelated content"
      }
    },
    urgent: {
      type:         "noul",
      instructions: "Does this message require an urgent response?"
    },
    harmful: {
      type:         "noul",
      instructions: "Does this message contain hate speech, threats, harassment, " \
                    "or other dangerous/harmful content?"
    }
  }.freeze

  model do
    use provider: :vercel, model: "typesafe-ai/jev", questions: QUESTIONS
  end
end
