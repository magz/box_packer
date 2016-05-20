require './assignment_strategy.rb'

class ImprovedStrategy < AssignmentStrategy

  attr_accessor :retired_machines, :acceptable_cost_ratio

  def initialize(server, acceptable_cost_ratio=3)
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

    @potential_carryover_jobs = []
    
    new_jobs.each do |job|
      potentially_assign_job(job)
      if @potential_carryover_jobs.count >= @acceptable_cost_ratio
        puts "threshold exceeded, creating new machine"
        new_machine = create_machine
        @available_machines.push new_machine
        @potential_carryover_jobs.each do |job|
          potentially_assign_job(job)
        end
        @potential_carryover_jobs = []
        puts "potential_carryover_jobs emptied"
        log_potential_carryover
      end
    end


    @available_machines.each(&:finalize_assignment!)
    if @potential_carryover_jobs.count > @acceptable_cost_ratio
      debugger
    end

    @potential_carryover_jobs
  end

  def log_potential_carryover
      puts "potential_carryover_jobs.count: #{@potential_carryover_jobs.count}"
      puts "potential_carryover_jobs ids: #{@potential_carryover_jobs.map(&:id)}"
  end
  def potentially_assign_job(job)
    best_fit_machine = 
      @available_machines
        .select {|machine| machine.available_memory >= job.memory_required }
        .min {|machine| machine.available_memory }
    
    if best_fit_machine
      best_fit_machine.assign_job job
    else
      @potential_carryover_jobs.push(job)
      puts "job #{job.id} didn't fit"
      log_potential_carryover    
    end
  end


  # def get_assignment_proposal(available_memory, jobs)
  #   proposed_jobs = []
  #   jobs.each do |job|
  #     if available_memory >= job.memory_required
  #       proposed_jobs.push job
  #       available_memory = available_memory - job.memory_required
  #     else
  #       return proposed_jobs
  #     end
  #   end
  #   proposed_jobs
  # end
end
