# Cross-checks two completely different approaches to the same question:
# ToxicityRequest (a classic prompted chat model, format :json) vs JevRequest
# (TypeSafe AI's Jev evaluation model, via Vercel AI Gateway). Verdict is true
# (safe) only when both agree there's no harmful content.
#
# The per-result block (not a `process` over the whole array) is deliberate:
# it works correctly regardless of which of the two requests fails or how
# they're ordered, because each result only carries the key that its own
# request type produces — see ToxicityRequest's "toxic" vs JevRequest's
# "harmful" key. Same technique SafetyTribunal already uses for
# toxic/aggressive.
class ContentSafetyTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  requests ToxicityRequest, JevRequest

  verdict :unanimous do |result|
    if result.processed&.key?("toxic")
      result.processed["toxic"] != true
    elsif result.processed&.key?("harmful")
      result.processed.dig("harmful", "noul").to_f < 0.5
    else
      false # unrecognized result shape — fail closed
    end
  end

  before(:call) do
    Rails.logger.info "[ContentSafetyTribunal] ▶ starting parallel checks…"
  end

  on(:after_request) do |result, index|
    Rails.logger.info "[ContentSafetyTribunal] ✓ request #{index + 1} done (#{result.execution_time}s) — #{result.processed}"
  end

  on(:request_error) do |name, error, _index|
    Rails.logger.warn "[ContentSafetyTribunal] ✗ #{name} error — #{error&.message}"
  end

  after(:verdict) do |verdict|
    verdict ? Rails.logger.info("[ContentSafetyTribunal] ✓ verdict: SAFE") : Rails.logger.warn("[ContentSafetyTribunal] ✗ verdict: FLAGGED")
  end
end
