module RequestMemory
  def self.included(base)
    base.before(:call) do
      @memory&.load
    end

    base.after(:call) do |result|
      next unless @memory
      @memory.record(
        request:       @input,
        response:      result.output,
        request_class: self.class.name,
        model:         result.model
      )
    end
  end
end
