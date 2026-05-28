require_relative "../agents/toxicity_agent"
require_relative "../agents/aggression_agent"

# Runs toxicity + aggression checks in parallel.
# Verdict is true (safe) when both agents report no issues.
class SafetyTribunal < ActiveHarness::Tribunal
  agents ToxicityAgent, AggressionAgent

  on(:before_call) do
    @otel_span = AiTracer.start_span("tribunal.call", attributes: { "tribunal.class" => self.class.name }, parent_ctx: @context[:otel_ctx])
    Rails.logger.info "[SafetyTribunal] ▶ starting parallel checks…"
  end

  on(:after_agent) do |result, index|
    @otel_span&.add_event("agent_done", attributes: {
      "agent.index" => index.to_s,
      "llm.model"   => result.model.to_s,
      "llm.time_s"  => result.execution_time.to_s
    })
    Rails.logger.info "[SafetyTribunal] ✓ agent #{index + 1} done (#{result.execution_time}s) — #{result.parsed}"
  end

  on(:agent_error) do |name, err, _i|
    @otel_span&.add_event("agent_error", attributes: { "agent.class" => name.to_s, "error" => err&.message.to_s })
    Rails.logger.warn "[SafetyTribunal] ✗ #{name} error — #{err&.message}"
  end

  on(:after_verdict) do |verdict|
    if @otel_span
      @otel_span.set_attribute("tribunal.verdict", verdict.to_s)
      @otel_span.set_attribute("tribunal.time_s",  execution_time.to_s)
      @otel_span.finish
      @otel_span = nil
    end
    verdict ? Rails.logger.info("[SafetyTribunal] ✓ verdict: PASS") : Rails.logger.warn("[SafetyTribunal] ✗ verdict: FAIL")
  end

  verdict :unanimous do |result|
    toxic      = result.parsed&.dig("toxic")
    aggressive = result.parsed&.dig("aggressive")
    toxic == false || aggressive == false
  end
end
