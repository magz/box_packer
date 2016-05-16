require './assignment_strategy.rb'

class AlwaysMakeNewMachineStrategy < AssignmentStrategy

  def initialize(server)
    @server = server
  end

  def assign_jobs(new_jobs)
    new_jobs.each do |job|
      new_machine = create_machine
      new_machine.assign_job(job)
      new_machine.finalize_assignment!
    end
  end


end



# COMPLETED GAME WITH:
# Total delay: 0 turns
# Total cost: $15619
