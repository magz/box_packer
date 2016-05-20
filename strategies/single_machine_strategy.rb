require './assignment_strategy.rb'

class SingleMachineStrategy < AssignmentStrategy

  def initialize(server, params)
    super 
    @available_machines = [create_machine]
  end

  def assign_jobs(new_jobs)
    machine = @available_machines.first
    new_jobs.each do |job|
      machine.assign_job(job)
      machine.finalize_assignment!
    end
  end
end



# Total delay: 82339 turns
# Total cost: $379
