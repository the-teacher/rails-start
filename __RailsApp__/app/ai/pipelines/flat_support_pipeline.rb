# Flat 6-step pipeline (no sub-pipeline nesting):
#   1. injection_guard — detect and block prompt injection attempts
#   2. translate       — normalise input to English
#   3. compact         — reduce to core intent
#   4. safety_tribunal — parallel toxicity + aggression check
#   5. relevance_guard — ensure the question is on-topic
#   6. respond         — produce the final answer
class FlatSupportPipeline < ActiveHarness::Pipeline
  include PipelineTracing

  step :injection_guard do
    use InjectionGuardAgent
    stop_if ->(result) { result.processed["detected"] == true }
  end

  step :translate, TranslationAgent

  step :compact, CompactionAgent

  step :safety_tribunal do
    use SafetyTribunal
    stop_if ->(result) { result.processed["verdict"] == false }
  end

  step :relevance_guard do
    use RelevanceAgent
    stop_if ->(result) { result.processed["relevant"] == false }
  end

  step :respond, SupportAgent

  before :step do |step_name, payload|
    Rails.logger.info "[FlatPipeline] ▶ before_step :#{step_name} | payload: #{payload.to_s.truncate(120)}"
  end

  after :step do |step_name, result|
    time = result.respond_to?(:execution_time) ? " (#{result.execution_time}s)" : ""
    Rails.logger.info "[FlatPipeline] ✓ after_step  :#{step_name}#{time}"
  end

  callback :stopped do |step_name, _result|
    Rails.logger.warn "[FlatPipeline] ✗ stopped at  :#{step_name}"
  end

  callback :complete do |_last_result|
    Rails.logger.info "[FlatPipeline] ✓ complete"
  end
end
