require './assignment_strategy.rb'

class ImprovedStrategy < AssignmentStrategy

  attr_accessor :retired_machines

  def initialize(server, cost_ratio)
    @server = server
    @available_machines = []
    @retired_machines = []
  end



  def assign_jobs(new_jobs)
    new_jobs = new_jobs.sort_by(&:memory_required).reverse

    @available_machines.select(&:deleteable?).each do |machine|
      retired_machines.push @available_machines.delete(machine)
      machine.destroy!
    end

    @available_machines.each do |machine|
      if new_jobs.length != 0 
        #check if pass by reference or w/e
        assign_jobs_to_machine(machine, new_jobs)
      end
    end

    while(new_jobs.length != 0)
      if create_new_machine?
        new_machine = create_machine
        puts "CREATED NEW MACHINE: #{new_machine.id}"
        @available_machines.push new_machine
        assign_jobs_to_machine(machine, new_jobs)
      else
        break
      end
    end

    @available_machines.each(&:finalize_assignment!)
    new_jobs
  end

  def create_new_machine?
    true
  end


  def assign_jobs_to_machine(machine, jobs)
    jobs.each_with_index do |job, i|
      if machine.available_memory == 0
        break
      end
      if machine.available_for_job?(job)
        machine.assign_job(job)
        jobs.delete_at(i)
      end
    end
  end
end



# COMPLETED GAME WITH:
# Total delay: 0 turns
# Total cost: $515
