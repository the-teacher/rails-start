# 4-step pipeline:
#   1. laundry          — inner PromptLaundryPipeline: injection guard + translate + compact
#   2. safety_tribunal  — parallel toxicity + aggression check on clean English text
#   3. relevance_guard  — ensure the question is on-topic
#   4. respond          — produce the final answer
class SupportPipeline < ActiveHarness::Pipeline
  include PipelineTracing

  STEPS = %i[laundry safety_tribunal relevance_guard respond].freeze

  # Step 1 — LAUNDRY: sanitise, translate, compact via inner pipeline
  step :laundry do
    use PromptLaundryPipeline
    transform { |result| result.output }
    stop_if   ->(result) { result.processed["stopped"] == true }
  end

  # Step 2 — TRIBUNAL: parallel toxicity + aggression check
  step :safety_tribunal do
    use SafetyTribunal
    stop_if ->(result) { result.processed["verdict"] == false }
  end

  # Step 3 — GUARD: topic relevance check
  step :relevance_guard do
    use RelevanceAgent
    stop_if ->(result) { result.processed["relevant"] == false }
  end

  # Step 4 — RESPOND: final answer on a clean, safe, on-topic, compact request
  step :respond, SupportAgent

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
