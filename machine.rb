class Machine
  TOTAL_MEMORY = 64
  
  attr_accessor :id, :new_jobs, :server, :activated_at, :deactivated_at
  def initialize(server)
    @server = server
    
    # Register machine with the server and assign id
    @id = server.create_machine['id']

    @new_jobs = []
    
    @activated_at = current_turn
    @deactivated_at = nil
  end

  # Is the machine currently doing any work?
  def deleteable?
    occupied_memory_hash[current_turn] == 0
  end

  def destroy!
    server.destroy_machine(self)
    @deactivated_at = current_turn
  end

  def available_for_job?(job, turn=current_turn)
    available_memory(turn) >= job.memory_required
  end

  def current_turn
    server.current_turn
  end

  def total_memory
    TOTAL_MEMORY
  end

  def occupied_memory_hash
    @occupied_memory_hash ||= Hash.new {|h,k| h[k] = 0 }
  end

  def available_memory(turn=current_turn)
    total_memory - occupied_memory_hash[turn]
  end

  def assign_job(job)
    @new_jobs.push(job)
    range_end = job.turns_required + current_turn
    (current_turn..range_end).each do |i|
      occupied_memory_hash[i] += job.memory_required
    end
  end

  def finalize_assignment!
    unless @new_jobs.empty?
      server.assign_jobs(self, @new_jobs)
      @new_jobs = []
    end
  end

  def efficiency
    turns_active = deactivated_at - activated_at
    blocks_used = occupied_memory_hash.values[0..-2].inject(0, :+)
    blocks_used.to_f / (turns_active * total_memory)
  end
end