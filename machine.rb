class Machine
  attr_accessor :id, :new_jobs, :server
  def initialize(server)
    @server = server
    @id = server.create_machine['id']
    @new_jobs = []
  end

  def totally_free?
    current_jobs.count == 0
  end

  def current_jobs
    raise 'undefined'
  end

  def total_memory
    64
  end

  def available_memory(turn)
    total_memory - assigned_jobs.select {|j| j.active_at_turn?(turn) }.map(&:memory_cost)
  end

  def assign_job(job)
    new_jobs.push(job)
  end

  def finalize_assignment!
    unless new_jobs.empty?
      server.assign_jobs(self, new_jobs)
    end
    @new_jobs = []
  end
end


