# Inner pipeline: sanitise, normalise, and compact a user request.
#
# Steps:
#   1. injection_guard — detect and block prompt injection attempts
#   2. translate       — normalise input to English for consistent downstream processing
#   3. compact         — reduce to core intent (saves tokens, removes noise)
#
# When used as a step in another pipeline, the result interface is:
#   result.output                       — clean compact English text (nil if stopped)
#   result.processed["stopped"]         — true when a guard stopped the pipeline
#   result.processed["stopped_at"]      — name of the step that triggered the stop
class PromptLaundryPipeline < ActiveHarness::Pipeline
  include PipelineTracing

  step :injection_guard do
    use InjectionGuardAgent
    stop_if ->(result) { result.processed["detected"] == true }
  end

  step :translate, TranslationAgent

  step :compact, CompactionAgent

  before :step do |step_name, payload|
    Rails.logger.info "[PromptLaundry] ▶ #{step_name} | #{payload.to_s.truncate(80)}"
  end

  after :step do |step_name, result|
    time = result.respond_to?(:execution_time) ? " (#{result.execution_time}s)" : ""
    Rails.logger.info "[PromptLaundry] ✓ #{step_name}#{time}"
  end

  callback :stopped do |step_name, _result|
    Rails.logger.warn "[PromptLaundry] ✗ stopped at :#{step_name}"
  end

  callback :complete do |_last_result|
    Rails.logger.info "[PromptLaundry] ✓ complete"
  end
end
