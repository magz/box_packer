require './assignment_strategy.rb'

class SingleMachineStrategy < AssignmentStrategy

  def initialize(server)
    @server = server
    @machines = [create_machine]
  end

  def assign_jobs(new_jobs)
    machine = @machines.first
    new_jobs.each do |job|
      machine.assign_job(job)
      machine.finalize_assignment!
    end
  end


end



# Total delay: 82339 turns
# Total cost: $379
