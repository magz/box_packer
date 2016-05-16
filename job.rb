class Job
  attr_accessor :id
  def initialize(id, memory_required, turns_required)
    @id = id
    @memory_required = memory_required
    @turns_required = turns_required
  end

end