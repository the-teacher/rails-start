# Runs SupportGuardRequest in parallel (single request here, extendable).
# Verdict is true (safe) when no spam is detected.
class SupportGuardTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  requests SupportGuardRequest

  process do |results|
    results.none? { |r| r.processed["spam"] == true }
  end
end
