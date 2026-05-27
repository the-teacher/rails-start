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

# Thin helper — returns a memoised tracer and wraps start_span so
# attribute values are always strings (OTel requires string/bool/numeric).
module AiTracer
  def self.tracer
    @tracer ||= OpenTelemetry.tracer_provider.tracer("active_harness")
  end

  def self.start_span(name, attributes: {})
    tracer.start_span(name, attributes: attributes.transform_values(&:to_s))
  end
end
