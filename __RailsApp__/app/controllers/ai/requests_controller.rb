module Ai
  class RequestsController < ApplicationController
    include ActionController::Live
    include Ai::RequestEvents
    layout "ai"

    skip_before_action :verify_authenticity_token

    # ---------------------------------------------------------------------------
    # GET /ai/requests/simple
    # Case 1: Simple request — no hooks, no streaming.
    # ---------------------------------------------------------------------------
    def simple
    end

    # POST /ai/requests/simple
    def simple_call
      req = SimpleRequest.call(input: params.require(:input))

      result = req.result
      render json: {
        output: result.output,
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  usage_json(result.usage),
        cost:   result.usage&.cost&.total
      }
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/streaming
    # Case 2: Same simple request but with token-by-token streaming via SSE.
    # No lifecycle sidebar.
    # ---------------------------------------------------------------------------
    def streaming
    end

    # GET /ai/requests/streaming/stream?input=...
    def streaming_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SimpleRequest.call(
        input:  input,
        token:  build_token_stream(sse_done)
      )

      result = req.result
      sse_done.write({ done: true, model: result.model&.name, time: result.execution_time, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/lifecycle
    # Case 3: Streaming + full lifecycle sidebar with request hook events.
    # (Kept identical to the original ai/support page)
    # ---------------------------------------------------------------------------
    def lifecycle
    end

    # GET /ai/requests/lifecycle/stream?input=...
    def lifecycle_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SupportRequest.call(
        input:  input,
        token:  build_token_stream(sse_done),
        stream: build_request_event_stream(sse)
      )

      result = req.result
      sse_done.write({ done: true, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/ruby_llm
    # Case 4: ruby_llm backend — streaming + lifecycle sidebar.
    # Same as Case 3 but HTTP calls go through the ruby_llm gem.
    # ---------------------------------------------------------------------------
    def ruby_llm
    end

    # GET /ai/requests/ruby_llm/stream?input=...
    def ruby_llm_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SupportRubyLLMRequest.call(
        input:  input,
        token:  build_token_stream(sse_done),
        stream: build_request_event_stream(sse)
      )

      result = req.result
      sse_done.write({ done: true, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/fallback
    # Case 5: Fallback chain demo — 2 intentionally broken models prepended via
    # req.models.prepend, then SupportRubyLLMRequest's own chain takes over.
    # The lifecycle sidebar shows :retry events for each failed model before
    # the first working model succeeds.
    # ---------------------------------------------------------------------------
    def fallback
    end

    # GET /ai/requests/fallback/stream?input=...
    def fallback_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SupportRubyLLMRequest.new(
        input:  input,
        token:  build_token_stream(sse_done),
        stream: build_request_event_stream(sse)
      )

      # Prepend 2 broken models — they will fail and trigger :retry events in the sidebar.
      req.models.prepend([
        { provider: :openrouter, model: "fake-provider/broken-model-one" },
        { provider: :openrouter, model: "fake-provider/broken-model-two" }
      ])

      req.call

      sse_done.write({ done: true, usage: usage_json(req.result&.usage), cost: req.result&.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/memory
    # Case 6: Memory request — conversation history persisted via JsonFile.
    # Each browser session gets its own memory file under storage/ai/memory/sessions/.
    # ---------------------------------------------------------------------------
    def memory
      @session_id = memory_session_id
      mem = AppMemory.new(file_name: "sessions/#{@session_id}")
      mem.load
      @history = mem.turns
    end

    # POST /ai/requests/memory/call
    def memory_call
      mem = AppMemory.new(file_name: "sessions/#{memory_session_id}")

      req = MemoryRequest.call(
        input:  params.require(:input),
        memory: mem
      )

      result = req.result
      render json: {
        output: result.output,
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  usage_json(result.usage),
        cost:   result.usage&.cost&.total
      }
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/image
    # Case 7: Image generation — OpenAI Images API, dall-e-2 256×256 ($0.016/img).
    # ---------------------------------------------------------------------------
    def image
    end

    # POST /ai/requests/image/call
    def image_call
      prompt = params.require(:input)
      req    = ImageRequest.call(input: prompt)
      result = req.result
      render json: {
        b64:   result.output,
        model: result.model&.name,
        time:  result.execution_time,
        usage: usage_json(result.usage),
        cost:  result.usage&.cost&.total
      }
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/transcribe
    # Case 8: Audio transcription — upload a file, get back the transcript text.
    # Synchronous call, no job id / polling — OpenRouter's transcription endpoint
    # returns the transcript directly (upstream providers time out after ~60s,
    # so long recordings should be split before uploading).
    # ---------------------------------------------------------------------------
    def transcribe
      @models = AudioTranscriptionRequest::MODELS
    end

    # POST /ai/requests/transcribe/call
    def transcribe_call
      file  = params.require(:audio)
      model = params[:model].presence

      raise ArgumentError, "Unknown model: #{model.inspect}" if model && !AudioTranscriptionRequest::MODELS.key?(model)

      req = AudioTranscriptionRequest.new(input: file.tempfile.path)
      req.models.replace([{ provider: :openrouter, model: model }]) if model
      req.call

      result = req.result
      render json: {
        text:  result.output,
        model: result.model&.name,
        time:  result.execution_time,
        usage: usage_json(result.usage),
        cost:  result.usage&.cost&.total
      }
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # POST /ai/requests/memory/clear
    def memory_clear
      sid = session[:ai_memory_id]
      if sid
        mem = AppMemory.new(file_name: "sessions/#{sid}")
        mem.load
        mem.delete
        session.delete(:ai_memory_id)
      end
      redirect_to ai_requests_memory_path
    end

    private

    def memory_session_id
      session[:ai_memory_id] ||= SecureRandom.hex(8)
    end

    def prepare_sse_response
      # ActionDispatch::ServerTiming crashes with ActionController::Live on Rails 8
      # because the events array is nil when the stream runs on a separate thread.
      request.env["action_dispatch.server_timing_events"] ||= []

      # Tell the browser this is a streaming SSE response, not a regular HTTP response.
      response.headers["Content-Type"]  = "text/event-stream"

      # Disable HTTP caching — every connection must reach the server.
      response.headers["Cache-Control"] = "no-cache"

      # Disable nginx / proxy buffering so tokens reach the browser immediately.
      response.headers["X-Accel-Buffering"] = "no"
    end

    def build_token_stream(sse)
      ->(token) { sse.write({ token: token }.to_json) }
    end

    def usage_json(usage)
      return nil unless usage
      { input: usage.tokens.input, output: usage.tokens.output, total: usage.tokens.total }
    end
  end
end
