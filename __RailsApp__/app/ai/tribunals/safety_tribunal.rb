# Runs toxicity + aggression checks in parallel.
# Verdict is true (safe) when both agents report no issues.
class SafetyTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  agents ToxicityAgent, AggressionAgent

  verdict :unanimous do |result|
    toxic      = result.processed&.dig("toxic")
    aggressive = result.processed&.dig("aggressive")
    toxic == false || aggressive == false
  end

  before(:call) do
    Rails.logger.info "[SafetyTribunal] ▶ starting parallel checks…"
  end

  on(:after_agent) do |result, index|
    Rails.logger.info "[SafetyTribunal] ✓ agent #{index + 1} done (#{result.execution_time}s) — #{result.processed}"
  end

  on(:agent_error) do |name, error, _index|
    Rails.logger.warn "[SafetyTribunal] ✗ #{name} error — #{error&.message}"
  end

  after(:verdict) do |verdict|
    verdict ? Rails.logger.info("[SafetyTribunal] ✓ verdict: PASS") : Rails.logger.warn("[SafetyTribunal] ✗ verdict: FAIL")
  end
end
