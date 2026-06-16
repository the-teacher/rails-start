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
    span = tracer.start_span(name, with_parent: ctx, attributes: attributes.transform_values(&:to_s))
    SpanWrapper.new(span)
  end

  # Wrap a span into an OTel Context so it can be passed as parent_ctx:.
  def self.span_context(span)
    span = span.unwrap if span.is_a?(SpanWrapper)
    OpenTelemetry::Trace.context_with_span(span)
  end

  # Wrapper for elegant span API
  class SpanWrapper
    def initialize(span)
      @span = span
    end

    def unwrap
      @span
    end

    # Set multiple attributes at once
    def attrs(hash)
      hash.each { |k, v| @span.set_attribute(k, v.to_s) }
      self
    end

    # Add event with nested attribute structure
    def event(name, **attrs)
      flat_attrs = flatten_attrs(attrs)
      @span.add_event(name, attributes: flat_attrs)
      self
    end

    # Finish the span
    def finish
      @span.finish
      self
    end

    # Delegate all other methods to underlying span
    def method_missing(method, *args, **kwargs)
      if @span.respond_to?(method)
        @span.public_send(method, *args, **kwargs)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @span.respond_to?(method) || super
    end

    private

    def flatten_attrs(hash, prefix = nil)
      hash.each_with_object({}) do |(key, value), result|
        full_key = prefix ? "#{prefix}.#{key}" : key.to_s
        if value.is_a?(Hash)
          result.merge!(flatten_attrs(value, full_key))
        else
          result[full_key] = value.to_s
        end
      end
    end
  end
end
