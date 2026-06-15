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

    def write_flat_pipeline_event(sse, name, args, step_index)
      payload = build_flat_pipeline_event(name, args, step_index)
      sse.write(payload.to_json)
    end

    def build_flat_pipeline_event(name, args, step_index)
      case name
      when :before_step then pipeline_step_start_event(args[0], step_index, "pipeline")
      when :after_step  then pipeline_step_done_event(args[0], args[1], "pipeline")
      when :stopped     then pipeline_stopped_event(args[0], args[1])
      when :complete    then pipeline_complete_event(false)
      else                   pipeline_generic_event(name)
      end
    end

    def write_pipeline_event(sse, name, args, step_index, in_laundry = false)
      payload = build_pipeline_event(name, args, step_index, in_laundry)
      sse.write(payload.to_json)
    end

    def write_tribunal_event(sse, name, args, agent_names)
      agent_names[args[1]] = args[0].class.name if name == :before_agent
      payload = build_tribunal_event(name, args, agent_names)
      sse.write(payload.to_json) if payload
    end

    def write_agent_event(sse, name, args)
      payload = build_agent_event(name, args)
      sse.write(payload.to_json) if payload
    end

    def build_pipeline_event(name, args, step_index, in_laundry = false)
      case name
      when :before_step
        source = LAUNDRY_INNER_STEPS.include?(args[0]) ? "laundry" : "pipeline"
        pipeline_step_start_event(args[0], step_index, source)
      when :after_step
        source = LAUNDRY_INNER_STEPS.include?(args[0]) ? "laundry" : "pipeline"
        pipeline_step_done_event(args[0], args[1], source)
      when :stopped     then pipeline_stopped_event(args[0], args[1])
      when :complete    then pipeline_complete_event(in_laundry)
      else                   pipeline_generic_event(name)
      end
    end

    def build_tribunal_event(name, args, agent_names = {})
      case name
      when :before_call    then tribunal_before_call_event
      when :after_call     then tribunal_after_call_event
      when :before_agent   then tribunal_before_agent_event(args, agent_names)
      when :after_agent    then tribunal_after_agent_event(args, agent_names)
      when :agent_error    then tribunal_agent_error_event(args)
      when :before_verdict then tribunal_before_verdict_event
      when :after_verdict  then tribunal_after_verdict_event(args[0])
      else                      tribunal_generic_event(name)
      end
    end

    def build_agent_event(name, args)
      case name
      when :setup       then nil
      when :before_call then agent_before_call_event
      when :after_call  then agent_after_call_event(args[0])
      when :retry       then agent_retry_event(args)
      when :failure     then agent_failure_event
      else                   nil
      end
    end

  end
end
