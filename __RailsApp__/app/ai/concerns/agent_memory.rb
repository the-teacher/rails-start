module AgentMemory
  def self.included(base)
    base.before(:call) do
      @memory&.load
    end

    base.after(:call) do |result|
      next unless @memory
      @memory.record(
        request:  @input,
        response: result.output,
        agent:    self.class.name,
        model:    result.model
      )
    end
  end
end
