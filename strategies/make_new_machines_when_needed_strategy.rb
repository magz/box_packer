require './assignment_strategy.rb'

#This was a first attempt to make a strategy that, as the name implies, creates a new machine whenver one is needed
#It worked fine, although the configurable strategy is able to do everything that this one can
#by setting the acceptable_cost_ratio to 0 and best_fit_strategy to first_fit
class MakeNewMachinesWhenNeededStrategy < AssignmentStrategy

  attr_accessor :retired_machines

  def initialize(server)
    @server = server
    @available_machines = []
    @retired_machines = []
  end



  def assign_jobs(new_jobs)
    new_jobs = new_jobs.sort_by(&:memory_required).reverse

    destroy_unused_machines

    new_jobs.each do |job|
      
      if available_machine = @available_machines.find {|m| m.available_for_job?(job)}
        available_machine.assign_job job
      else
        new_machine = create_machine
        puts "CREATED NEW MACHINE: #{new_machine.id}"

        @available_machines.push new_machine
        new_machine.assign_job job
      end
    end

    @available_machines.each(&:finalize_assignment!)
  end


end



# {"id":15931,"cost":515,"current_turn":57,"completed":true,"created_at":"2016-05-16T23:32:13.000Z","updated_at":"2016-05-16T23:33:26.000Z","jobs_completed":492,"total_score":192.0,"cost_score":92.0,"time_score":100.0,"short":true,"delay_turns":0}


# COMPLETED GAME WITH:
# Total delay: 0 turns
# Total cost: $515


