require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"

OpenTelemetry::SDK.configure do |c|
  c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "active_harness_rails")

  exporter = OpenTelemetry::Exporter::OTLP::Exporter.new(
    # /v1/traces is required when passing endpoint directly (not via env var)
    endpoint: ENV.fetch("OTEL_EXPORTER_OTLP_ENDPOINT", "http://jaeger:4318/v1/traces")
  )

  # SimpleSpanProcessor sends each span immediately — ideal for development.
  # Replace with BatchSpanProcessor in production.
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(exporter)
  )
end

# Thin helper around the OTel tracer.
module AiTracer
  def self.tracer
    @tracer ||= OpenTelemetry.tracer_provider.tracer("active_harness")
  end

  # Start a span, optionally as a child of parent_ctx.
  # parent_ctx is an OpenTelemetry::Context returned by span_context(span).
  def self.start_span(name, attributes: {}, parent_ctx: nil)
    ctx = parent_ctx || OpenTelemetry::Context.current
    tracer.start_span(name, with_parent: ctx, attributes: attributes.transform_values(&:to_s))
  end

  # Wrap a span into an OTel Context so it can be passed as parent_ctx:.
  def self.span_context(span)
    OpenTelemetry::Trace.context_with_span(span)
  end
end
