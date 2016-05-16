class Machine
  attr_accessor :id, :new_jobs, :server
  def initialize(server)
    @server = server
    @id = server.create_machine['id']
  end

  def totally_free?
    current_jobs.count == 0
  end

  def current_jobs
    raise 'undefined'
  end

  def current_turn
    server.current_turn
  end

  def assigned_jobs_log
    @assigned_jobs_log ||= Hash.new {|h,k| h[k] = [] }
  end

  def new_jobs
    assigned_jobs_log[current_turn]
  end

  def total_memory
    64
  end

  def available_memory
    total_memory - assigned_jobs.select {|j| j.active_at_turn?(turn) }.map(&:memory_cost)
  end


  def assign_job(job)
    new_jobs.push(job)
  end

  def finalize_assignment!
    unless new_jobs.empty?
      server.assign_jobs(self, new_jobs)
    end
  end
end


