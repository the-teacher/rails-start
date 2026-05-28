require_relative "../agents/support_guard_agent"

# Runs SupportGuardAgent in parallel (single agent here, extendable).
# Verdict is true (safe) when no spam is detected.
class SupportGuardTribunal < ActiveHarness::Tribunal
  agents SupportGuardAgent

  on(:before_call)   { @otel_span = AiTracer.start_span("tribunal.call", attributes: { "tribunal.class" => self.class.name }, parent_ctx: @context[:otel_ctx]) }

  on(:after_verdict) do |verdict|
    if @otel_span
      @otel_span.set_attribute("tribunal.verdict", verdict.to_s)
      @otel_span.finish
      @otel_span = nil
    end
  end

  process do |results|
    results.none? { |r| r.parsed["spam"] == true }
  end
end
