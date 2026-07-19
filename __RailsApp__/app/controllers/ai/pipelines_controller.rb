module Ai
  class PipelinesController < ApplicationController
    include ActionController::Live
    include Ai::PipelineEvents
    layout "ai"

    skip_before_action :verify_authenticity_token

    # GET /ai/pipelines/support
    def support
    end

    # GET /ai/pipelines/flat
    def flat
    end

    OPENAI_PRICING_CACHE_KEY = "openai_pricing_pipeline_result"
    OPENAI_PRICING_CACHE_TTL = 24.hours

    # GET /ai/pipelines/openai_pricing
    def openai_pricing
    end

    # GET /ai/pipelines/openai_pricing/cached
    def openai_pricing_cached
      cached = Rails.cache.read(OPENAI_PRICING_CACHE_KEY)
      if cached
        render json: cached
      else
        render json: { success: false, cached: false }
      end
    end

    # POST /ai/pipelines/openai_pricing/run
    def openai_pricing_run
      pipeline = OpenAiPricingPipeline.new(input: nil)
      pipeline.call

      fetch_result   = nil
      extract_result = nil
      pipeline.steps do |name, _executor, result|
        fetch_result   = result if name == :fetch_page
        extract_result = result if name == :extract_pricing
      end

      models = extract_result&.processed&.dig("models") || []

      usage = extract_result&.usage

      payload = {
        success:        true,
        cached:         false,
        cached_at:      nil,
        models:         models,
        total_time:     pipeline.execution_time,
        fetch_time:     fetch_result&.execution_time,
        extract_time:   extract_result&.execution_time,
        text_length:    fetch_result&.processed&.dig("text_length"),
        model_used:     extract_result&.model&.name,
        tokens_input:   usage&.tokens&.input,
        tokens_output:  usage&.tokens&.output,
        cost_total:     usage&.cost&.total
      }

      Rails.cache.write(
        OPENAI_PRICING_CACHE_KEY,
        payload.merge(cached: true, cached_at: Time.current.iso8601),
        expires_in: OPENAI_PRICING_CACHE_TTL
      )

      render json: payload
    rescue StandardError => e
      Rails.logger.error "[OpenAiPricingPipeline] error: #{e.class}: #{e.message}"
      render json: { success: false, error: "#{e.class.name.split('::').last}: #{e.message}" }, status: 422
    end

    # GET /ai/pipelines/flat/stream?input=...
    def flat_stream
      prepare_sse_response

      input    = params.require(:input)
      sse      = ActionController::Live::SSE.new(response.stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(response.stream, event: "completion")

      @step_index           = 0
      @tribunal_agent_names = {}

      pipeline = FlatSupportPipeline.new(
        input:  input,
        stream: build_flat_pipeline_stream(sse)
      )
      pipeline.call

      sse_done.write({
        done:       true,
        stopped:    pipeline.stopped?,
        stopped_at: pipeline.stopped_at,
        output:     pipeline.output,
        time:       pipeline.execution_time
      }.to_json)
    rescue ActionController::Live::ClientDisconnected
      # ignore
    rescue StandardError => e
      sse_done.write({ error: "#{e.class.name.split("::").last}: #{e.message}" }.to_json) rescue nil
      sse_done.write({ done: true }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # GET /ai/pipelines/support/stream?input=...
    def support_stream
      prepare_sse_response

      input    = params.require(:input)
      sse      = ActionController::Live::SSE.new(response.stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(response.stream, event: "completion")

      @step_index           = 0
      @in_laundry           = false
      @tribunal_agent_names = {}

      pipeline = SupportPipeline.new(
        input:  input,
        stream: build_support_pipeline_stream(sse)
      )
      pipeline.call

      sse_done.write({
        done:       true,
        stopped:    pipeline.stopped?,
        stopped_at: pipeline.stopped_at,
        output:     pipeline.output,
        time:       pipeline.execution_time
      }.to_json)
    rescue ActionController::Live::ClientDisconnected
      # ignore
    rescue StandardError => e
      sse_done.write({ error: "#{e.class.name.split("::").last}: #{e.message}" }.to_json) rescue nil
      sse_done.write({ done: true }.to_json) rescue nil
    ensure
      sse_done.close
    end

    private

    def prepare_sse_response
      request.env["action_dispatch.server_timing_events"] ||= []
      response.headers["Content-Type"]      = "text/event-stream"
      response.headers["Cache-Control"]     = "no-cache"
      response.headers["X-Accel-Buffering"] = "no"
    end

    def build_flat_pipeline_stream(sse)
      lambda do |source, event, *args|
        case source
        when :pipeline
          write_flat_pipeline_event(sse, event, args, @step_index)
          @step_index += 1 if event == :before_step
        when :tribunal then write_tribunal_event(sse, event, args, @tribunal_agent_names)
        when :agent    then write_agent_event(sse, event, args)
        end
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def build_support_pipeline_stream(sse)
      lambda do |source, event, *args|
        case source
        when :pipeline
          @in_laundry = true  if event == :before_step && args[0]&.to_sym == :laundry
          @in_laundry = false if event == :after_step  && args[0]&.to_sym == :laundry
          @in_laundry = false if event == :stopped     && args[0]&.to_sym == :laundry
          write_pipeline_event(sse, event, args, @step_index, @in_laundry)
          @step_index += 1 if event == :before_step
        when :tribunal then write_tribunal_event(sse, event, args, @tribunal_agent_names)
        when :agent    then write_agent_event(sse, event, args)
        end
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

  end
end
