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
    new_jobs = new_jobs.sort_by(&:memory_required)


    @available_machines.select(&:deleteable?).each do |machine|
      retired_machines.push @available_machines.delete(machine)
      machine.destroy!
    end

    assigned_jobs = []
    new_jobs.each do |job|
      @available_machines.each do |machine|
        if machine.available_for_job?(job)
          machine.assign_job(job)
          assigned_jobs.push(job)
        end
      end
    end
    new_jobs = new_jobs - assigned_jobs

    if new_jobs.length != 0
      proposed_jobs = get_assignment_proposal(64, new_jobs)
      if create_new_machine_for_jobs?(proposed_jobs)
        new_machine = create_machine
        @available_machines.push new_machine
        cost = proposed_jobs.map(&:memory_required).inject(0, &:+)
        new_machine.assign_jobs(proposed_jobs)
        new_jobs = new_jobs - proposed_jobs
      end
    end

    if new_jobs.length != 0
      proposed_jobs = get_assignment_proposal(64, new_jobs)
      if create_new_machine_for_jobs?(proposed_jobs)
        new_machine = create_machine
        @available_machines.push new_machine
        cost = proposed_jobs.map(&:memory_required).inject(0, &:+)
        new_machine.assign_jobs(proposed_jobs)
        new_jobs = new_jobs - proposed_jobs
      end
    end


    @available_machines.each(&:finalize_assignment!)
    if new_jobs.count != 0
      debugger
    end

    new_jobs
  end

  def create_new_machine_for_jobs?(jobs)
    jobs.length >= acceptable_cost_ratio
  end


  # def assign_jobs_to_machine(machine, jobs)
  #   proposed_jobs = get_assignment_proposal(machine.available_memory, jobs)
  #   machine.assign_jobs(proposed_jobs)
  #   machine.finalize_assignment!
  #   remaining_jobs = jobs - proposed_jobs
  #   remaining_jobs
  # end

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
