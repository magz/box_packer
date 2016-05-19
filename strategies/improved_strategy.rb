require './assignment_strategy.rb'

class ImprovedStrategy < AssignmentStrategy

  attr_accessor :retired_machines, :acceptable_cost_ratio

  def initialize(server, acceptable_cost_ratio=1)
    @server = server
    @available_machines = []
    @retired_machines = []
    @acceptable_cost_ratio = acceptable_cost_ratio
  end



  def assign_jobs(new_jobs)
    new_jobs = new_jobs.sort_by(&:memory_required).reverse


    @available_machines.select(&:deleteable?).each do |machine|
      retired_machines.push @available_machines.delete(machine)
      machine.destroy!
    end

    # current_capacity = available_machines.map(&:available_memory).inject(0, &:+)
    # total_memory_required_for_new_jobs = new_jobs.map(&:memory_required).inject(0, &:+)

    assigned_jobs = []
    new_jobs.each do |job|
      candidate_machines = @available_machines.select {|machine| (machine.available_memory >= job.memory_required)}
      if candidate_machines.length != 0
        best_fit = candidate_machines.min {|machine| machine.available_memory}
        best_fit.assign_job(job)
        assigned_jobs.push job
      end
    end

    new_jobs = new_jobs - assigned_jobs



    @available_machines.each(&:finalize_assignment!)
    if new_jobs.count != 0
      debugger
    end

    new_jobs
  end

  def create_new_machine_for_jobs?(jobs)
    jobs.length >= acceptable_cost_ratio
  end


  def get_assignment_proposal(available_memory, jobs)
    proposed_jobs = []
    jobs.each do |job|
      if available_memory >= job.memory_required
        proposed_jobs.push job
        available_memory = available_memory - job.memory_required
      else
        return proposed_jobs
      end
    end
    proposed_jobs
  end
end
