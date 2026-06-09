# Runs SupportGuardAgent in parallel (single agent here, extendable).
# Verdict is true (safe) when no spam is detected.
class SupportGuardTribunal < ActiveHarness::Tribunal
  include TribunalTracing

  agents SupportGuardAgent

  process do |results|
    results.none? { |r| r.processed["spam"] == true }
  end
end
