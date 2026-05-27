require_relative "../agents/toxicity_agent"
require_relative "../agents/aggression_agent"

# Runs toxicity + aggression checks in parallel.
# Verdict is true (safe) when both agents report no issues.
class SafetyTribunal < ActiveHarness::Tribunal
  agents ToxicityAgent, AggressionAgent

  on(:before_call)   { Rails.logger.info  "[SafetyTribunal] ▶ starting parallel checks…" }
  on(:after_agent)   { |result, index| Rails.logger.info  "[SafetyTribunal] ✓ agent #{index + 1} done (#{result.execution_time}s) — #{result.parsed}" }
  on(:agent_error)   { |name, err, _i| Rails.logger.warn  "[SafetyTribunal] ✗ #{name} error — #{err&.message}" }
  on(:after_verdict) { |verdict| verdict ? Rails.logger.info("[SafetyTribunal] ✓ verdict: PASS") : Rails.logger.warn("[SafetyTribunal] ✗ verdict: FAIL") }

  verdict :unanimous do |result|
    toxic      = result.parsed&.dig("toxic")
    aggressive = result.parsed&.dig("aggressive")
    toxic == false || aggressive == false
  end
end
