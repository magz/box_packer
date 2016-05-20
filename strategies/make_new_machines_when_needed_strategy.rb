require './assignment_strategy.rb'

#This was a first attempt to make a strategy that, as the name implies, creates a new machine whenver one is needed
#It worked fine, although the configurable strategy is able to do everything that this one can
#by setting the acceptable_cost_ratio to 0 and best_fit_strategy to first_fit
class MakeNewMachinesWhenNeededStrategy < AssignmentStrategy
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

# COMPLETED GAME WITH:
# Total delay: 0 turns
# Total cost: $515


