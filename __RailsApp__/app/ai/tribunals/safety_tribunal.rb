# Runs toxicity + aggression checks in parallel.
# Verdict is true (safe) when both requests report no issues.
class SafetyTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  requests ToxicityRequest, AggressionRequest

  verdict :unanimous do |result|
    toxic      = result.processed&.dig("toxic")
    aggressive = result.processed&.dig("aggressive")
    toxic == false || aggressive == false
  end

  before(:call) do
    Rails.logger.info "[SafetyTribunal] ▶ starting parallel checks…"
  end

  on(:after_request) do |result, index|
    Rails.logger.info "[SafetyTribunal] ✓ request #{index + 1} done (#{result.execution_time}s) — #{result.processed}"
  end

  on(:request_error) do |name, error, _index|
    Rails.logger.warn "[SafetyTribunal] ✗ #{name} error — #{error&.message}"
  end

  after(:verdict) do |verdict|
    verdict ? Rails.logger.info("[SafetyTribunal] ✓ verdict: PASS") : Rails.logger.warn("[SafetyTribunal] ✗ verdict: FAIL")
  end
end
