require_relative "../tribunals/support_guard_tribunal"
require_relative "../agents/support_agent"

# Two-step pipeline: spam guard → answer.
# Add more steps between them as needed.
class SupportPipeline < ActiveHarness::Pipeline
  # Step 1 — GUARD: reject spam before spending tokens on an answer
  step :spam_guard do
    use SupportGuardTribunal
    stop_if ->(result) { result.verdict == false }
  end

  # Step 2 — RESPOND: generate the actual answer
  step :respond, SupportAgent

  before :step do |step_name, _payload|
    puts "[pipeline] → :#{step_name}"
  end

  after :step do |step_name, _result|
    puts "[pipeline] ✓ :#{step_name}"
  end

  callback :stopped do |step_name, _result|
    puts "[pipeline] ✗ STOPPED at :#{step_name}"
  end

  callback :complete do |_last_result|
    puts "[pipeline] ✓ complete"
  end
end
