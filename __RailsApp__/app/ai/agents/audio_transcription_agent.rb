class AudioTranscriptionAgent < ActiveHarness::Agent
  transcribe true

  # Models available on OpenRouter with an "AuTR" (audio transcription) tag.
  MODELS = {
    "openai/whisper-1"                  => "OpenAI: Whisper 1",
    "openai/whisper-large-v3"           => "OpenAI: Whisper Large V3",
    "openai/whisper-large-v3-turbo"     => "OpenAI: Whisper Large V3 Turbo",
    "openai/gpt-4o-mini-transcribe"     => "OpenAI: GPT-4o Mini Transcribe",
    "openai/gpt-4o-transcribe"          => "OpenAI: GPT-4o Transcribe",
    "deepgram/nova-3"                   => "Deepgram: Nova-3",
    "google/chirp-3"                    => "Google: Chirp 3",
    "microsoft/mai-transcribe-1.5"      => "Microsoft: MAI-Transcribe 1.5",
    "mistralai/voxtral-mini-transcribe" => "Mistral: Voxtral Mini Transcribe",
    "nvidia/parakeet-tdt-0.6b-v3"       => "NVIDIA: Parakeet TDT 0.6B v3",
    "qwen/qwen3-asr-flash-2026-02-10"   => "Qwen: Qwen3 ASR Flash"
  }.freeze

  DEFAULT_MODEL = "openai/whisper-1".freeze

  model do
    use      provider: :openrouter, model: DEFAULT_MODEL
    fallback provider: :openrouter, model: "deepgram/nova-3"
  end
end
