# 6-step pipeline:
#   1. injection_guard  — block prompt-injection attempts
#   2. translate        — normalise to English for downstream steps
#   3. compact          — reduce to core intent (saves tokens)
#   4. safety_tribunal  — parallel toxicity + aggression check
#   5. relevance_guard  — ensure the question is on-topic
#   6. respond          — produce the final answer
#
# Accepts a streams: hash forwarded to agents and tribunals:
#   streams: {
#     pipeline:  pipeline lifecycle events (:before_step, :after_step, :stopped, :complete)
#     tribunal:  forwarded to every tribunal step
#     agent:     forwarded to every agent step
#     token:     token stream forwarded to agents
#   }
class SupportPipeline < ActiveHarness::Pipeline
  include PipelineTracing

  STEPS = %i[injection_guard translate compact safety_tribunal relevance_guard respond].freeze

  # Step 1 — GUARD: detect prompt injection before wasting tokens
  step :injection_guard do
    use InjectionGuardAgent
    stop_if ->(result) { result.processed["detected"] == true }
  end

  # Step 2 — TRANSFORM: translate to English for consistent downstream processing
  step :translate, TranslationAgent

  # Step 3 — TRANSFORM: compact to key intent, reduces tokens for expensive steps
  step :compact, CompactionAgent

  # Step 4 — TRIBUNAL: parallel toxicity + aggression check on compact English text
  step :safety_tribunal do
    use SafetyTribunal
    stop_if ->(result) { result.verdict == false }
  end

  # Step 5 — GUARD: topic relevance check
  step :relevance_guard do
    use RelevanceAgent
    stop_if ->(result) { result.processed["relevant"] == false }
  end

  # Step 6 — RESPOND: final answer on a clean, safe, on-topic, compact request
  step :respond, SupportAgent

  # ── Hooks ──

  before :step do |step_name, payload|
    Rails.logger.info "[Pipeline] ▶ before_step :#{step_name} | payload: #{payload.to_s.truncate(120)}"
  end

  after :step do |step_name, result|
    time = result.respond_to?(:execution_time) ? " (#{result.execution_time}s)" : ""
    Rails.logger.info "[Pipeline] ✓ after_step  :#{step_name}#{time}"
  end

  callback :stopped do |step_name, _result|
    Rails.logger.warn "[Pipeline] ✗ stopped at  :#{step_name}"
  end

  callback :complete do |_last_result|
    Rails.logger.info "[Pipeline] ✓ complete"
  end
end
