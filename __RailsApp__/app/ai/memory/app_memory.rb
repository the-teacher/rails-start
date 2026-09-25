class AppMemory < ActiveHarness::Memory::JsonFile
  def initialize(file_name:, **opts)
    super(
      file_name:    file_name,
      storage_path: Rails.root.join("storage", "ai", "memory").to_s,
      depth:        10,
      storage_size: 200,
      pretty:       Rails.env.development?,
      **opts
    )
  end
end
