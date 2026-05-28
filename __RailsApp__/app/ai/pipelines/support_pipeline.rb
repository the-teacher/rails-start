require_relative "../agents/injection_guard_agent"
require_relative "../agents/translation_agent"
require_relative "../agents/compaction_agent"
require_relative "../tribunals/safety_tribunal"
require_relative "../agents/relevance_agent"
require_relative "../agents/support_agent"

# 6-step pipeline:
#   1. injection_guard  — block prompt-injection attempts
#   2. translate        — normalise to English for downstream steps
#   3. compact          — reduce to core intent (saves tokens)
#   4. safety_tribunal  — parallel toxicity + aggression check
#   5. relevance_guard  — ensure the question is on-topic
#   6. respond          — produce the final answer
#
# Accepts a streams: hash forwarded to agents and tribunals:
#   streams: {
#     pipeline:  pipeline lifecycle events (:before_step, :after_step, :stopped, :complete)
#     tribunal:  forwarded to every tribunal step
#     agent:     forwarded to every agent step
#     token:     token stream forwarded to agents
#   }
class SupportPipeline < ActiveHarness::Pipeline
  STEPS = %i[injection_guard translate compact safety_tribunal relevance_guard respond].freeze

  # Step 1 — GUARD: detect prompt injection before wasting tokens
  step :injection_guard do
    use InjectionGuardAgent
    stop_if ->(result) { result.parsed["detected"] == true }
  end

  # Step 2 — TRANSFORM: translate to English for consistent downstream processing
  step :translate, TranslationAgent

  # Step 3 — TRANSFORM: compact to key intent, reduces tokens for expensive steps
  step :compact, CompactionAgent

  # Step 4 — TRIBUNAL: parallel toxicity + aggression check on compact English text
  step :safety_tribunal do
    use SafetyTribunal
    stop_if ->(result) { result.verdict == false }
  end

  # Step 5 — GUARD: topic relevance check
  step :relevance_guard do
    use RelevanceAgent
    stop_if ->(result) { result.parsed["relevant"] == false }
  end

  # Step 6 — RESPOND: final answer on a clean, safe, on-topic, compact request
  step :respond, SupportAgent

  # ── Hooks — all events auto-forwarded to pipeline_event_stream by Pipeline#fire ──

  before :step do |step_name, payload|
    @otel_spans ||= {}

    # Create the root pipeline span once on the first step.
    unless @otel_pipeline_span
      @otel_pipeline_span = AiTracer.start_span("pipeline", attributes: {
        "pipeline.class" => self.class.name
      })
      @otel_pipeline_ctx = AiTracer.span_context(@otel_pipeline_span)
    end

    # Each step span is a child of the root pipeline span.
    step_span = AiTracer.start_span("pipeline.step", attributes: {
      "pipeline.class" => self.class.name,
      "step.name"      => step_name.to_s
    }, parent_ctx: @otel_pipeline_ctx)
    @otel_spans[step_name] = step_span

    # Inject step span context into @context so agents/tribunals become children.
    @context[:otel_ctx] = AiTracer.span_context(step_span)

    Rails.logger.info "[Pipeline] ▶ before_step :#{step_name} | payload: #{payload.to_s.truncate(120)}"
  end

  after :step do |step_name, result|
    if (span = @otel_spans&.delete(step_name))
      span.set_attribute("llm.time_s", result.execution_time.to_s) if result.respond_to?(:execution_time)
      span.set_attribute("llm.model",  result.model.to_s)          if result.respond_to?(:model)
      span.finish
    end
    time = result.respond_to?(:execution_time) ? " (#{result.execution_time}s)" : ""
    Rails.logger.info "[Pipeline] ✓ after_step  :#{step_name}#{time}"
  end

  callback :stopped do |step_name, result|
    if (span = @otel_spans&.delete(step_name))
      span.set_attribute("pipeline.stopped", "true")
      span.finish
    end
    if @otel_pipeline_span
      @otel_pipeline_span.set_attribute("pipeline.stopped_at", step_name.to_s)
      @otel_pipeline_span.finish
      @otel_pipeline_span = nil
    end
    Rails.logger.warn "[Pipeline] ✗ stopped at  :#{step_name}"
  end

  callback :complete do |last_result|
    if @otel_pipeline_span
      @otel_pipeline_span.set_attribute("pipeline.time_s", execution_time.to_s)
      @otel_pipeline_span.finish
      @otel_pipeline_span = nil
    end
    Rails.logger.info "[Pipeline] ✓ complete"
  end
end
