class AppMemory < ActiveHarness::Memory
  # Usage: AppMemory.new(session_id: "user_42")
  #
  # Wraps ActiveHarness::Memory with project defaults so callers
  # only need to pass a session_id.
  def initialize(session_id:)
    super(
      session_id:   session_id,
      depth:        10,
      adapter:      :file,
      path:         Rails.root.join("storage", "ai", "memory").to_s,
      storage_size: 200,
      pretty:       Rails.env.development?
    )
  end
end
