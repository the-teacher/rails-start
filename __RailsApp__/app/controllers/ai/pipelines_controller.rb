module Ai
  class PipelinesController < ApplicationController
    include ActionController::Live
    include Ai::PipelineEvents
    layout "ai"

    skip_before_action :verify_authenticity_token

    # GET /ai/pipelines/support
    def support
    end

    # GET /ai/pipelines/support/stream?input=...
    def support_stream
      prepare_sse_response

      input    = params.require(:input)
      sse      = ActionController::Live::SSE.new(response.stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(response.stream, event: "completion")

      @step_index           = 0
      @tribunal_agent_names = {}

      pipeline = SupportPipeline.new(
        input:   input,
        streams: {
          pipeline: pipeline_stream(sse),
          tribunal: tribunal_stream(sse),
          agent:    agent_stream(sse)
        }
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

    def pipeline_stream(sse)
      lambda do |name, *args|
        write_pipeline_event(sse, name, args, @step_index)
        @step_index += 1 if name == :before_step
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def tribunal_stream(sse)
      lambda do |name, *args|
        write_tribunal_event(sse, name, args, @tribunal_agent_names)
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def agent_stream(sse)
      lambda do |name, *args|
        write_agent_event(sse, name, args)
      rescue IOError, ActionController::Live::ClientDisconnected
      end
    end

    def write_pipeline_event(sse, name, args, step_index)
      payload = build_pipeline_event(name, args, step_index)
      sse.write(payload.to_json)
    end

    def write_tribunal_event(sse, name, args, agent_names)
      agent_names[args[1]] = args[0].class.name.delete_suffix("Agent") if name == :before_agent
      payload = build_tribunal_event(name, args, agent_names)
      sse.write(payload.to_json) if payload
    end

    def write_agent_event(sse, name, args)
      payload = build_agent_event(name, args)
      sse.write(payload.to_json) if payload
    end

    def build_pipeline_event(name, args, step_index)
      case name
      when :before_step then pipeline_step_start_event(args[0], step_index)
      when :after_step  then pipeline_step_done_event(args[0], args[1])
      when :stopped     then pipeline_stopped_event(args[0], args[1])
      when :complete    then pipeline_complete_event
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

    def step_result_summary(step_name, result)
      case step_name
      when :injection_guard  then result.processed&.dig("detected") ? "INJECTION" : "clean"
      when :translate        then truncate_output(result.output, 60)
      when :compact          then truncate_output(result.output, 60)
      when :safety_tribunal
        v = result.respond_to?(:verdict) ? result.verdict : nil
        v.nil? ? nil : (v ? "SAFE" : "UNSAFE")
      when :relevance_guard  then result.processed&.dig("relevant") ? "relevant" : "off-topic"
      when :respond          then truncate_output(result.output, 80)
      end
    end

    def stop_reason_text(step_name, result)
      case step_name
      when :injection_guard
        result.processed&.dig("reason") || "injection detected"
      when :safety_tribunal
        "content failed safety check"
      when :relevance_guard
        result.processed&.dig("reason") || "off-topic"
      else
        "condition met"
      end
    end

    # Returns [text_detail, log_level] for a single tribunal agent result.
    # Extracts the named boolean field ("toxic", "aggressive", etc.) and optional "reason".
    def tribunal_agent_detail(parsed)
      return ["no data", "info"] unless parsed.is_a?(Hash)

      # Find the first boolean flag field (toxic, aggressive, …)
      flag_key, flag_val = parsed.find { |k, v| v == true || v == false }

      unless flag_key
        snippet = parsed.to_s[0..50]
        return [snippet, "info"]
      end

      reason = parsed["reason"].to_s.strip
      reason = reason.empty? ? nil : reason[0..60]

      if flag_val == false
        detail = "#{flag_key}: ✓ ok"
        [reason ? "#{detail} — #{reason}" : detail, "success"]
      else
        detail = "#{flag_key}: ✗ detected"
        [reason ? "#{detail} — #{reason}" : detail, "warning"]
      end
    end
  end
end
