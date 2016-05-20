require './assignment_strategy.rb'
require 'profile'

# This is the final Strategy I developed.  It allows configuration of both the maximum number of jobs
# to carryover between rounds (which is proportional to the ratio between delay turns and cost, provided
# that the value is not too high).
# The find_best_fit_machine_strategy controls how to match jobs to machines, with performance tradoffs described below.
class ConfigurableStrategy < AssignmentStrategy

  def initialize(server, params)
    super

    @acceptable_cost_ratio = @params[:acceptable_cost_ratio] || 2
    @find_best_fit_machine_strategy = @params[:find_best_fit_machine_strategy] || 'first_fit'
  end



  def assign_jobs(new_jobs)
    new_jobs = new_jobs.sort_by(&:memory_required).reverse

    #this is currently running on every iteration
    #this could possibly be refined in a few ways
    #a) Only check for deletion every Nth iteration
    #b) Based on the rising and then falling input pattern from the server
        # You could check every Nth iteration, and then every iteration once you get a deletion
    destroy_unused_machines
    
    #an array to track jobs we might carry over until the next turn
    @potential_carryover_jobs = []
    while(new_jobs.length > 0)
      #get next job
      job = new_jobs.pop
      # see if there's a machine available to take the job
      potentially_assign_job(job)
      # Have we accumulated enough jobs to warrant creating a new machine, based on our input for valuing delay vs cost
      # DOES THIS HAVE PROBLEMS IF THE RATIO IS TOO LARGE???
      if @potential_carryover_jobs.count >= @acceptable_cost_ratio
        create_machine
        # Add our potential carryover jobs back to our queue of new jobs try to place, 
        # now that we have a new machine
        new_jobs = new_jobs + @potential_carryover_jobs

        # We can now clear our carryover jobs
        @potential_carryover_jobs = []

        log_potential_carryover
      end
    end

    #tell each machine to send a message to the server registering the jobs we've assigned
    @available_machines.each(&:finalize_assignment!)

    # I opted to manually control the carryover of jobs between rounds, rather than using the queing method
    # While Machine#occupied_memory_hash would allow for placing jobs into a machine's queue, I didn't do this for a few reasons
    # Pros (to my approach):
      # More efficient distribution of jobs to machines in rounds, because you have more knowledge of incoming jobs
      # Quicker scale down of unneeded machines
    # Cons
      # More time spent calculating job assignment
      # More http calls to assign jobs (this is largely mitigated by batched job assignment)  
    @potential_carryover_jobs
  end

  def log_potential_carryover
      # puts "potential_carryover_jobs.count: #{@potential_carryover_jobs.count}"
      # puts "potential_carryover_jobs ids: #{@potential_carryover_jobs.map(&:id)}"
  end
  def potentially_assign_job(job)
    # Find out which machine is the best match
    best_fit_machine = find_best_fit_machine(job)
    
    if best_fit_machine
      # We found a machine to assign the job to!
      best_fit_machine.assign_job job
    else
      # We didn't find a machine, and might want to carry it over to the next turn
      @potential_carryover_jobs.push(job)
      # puts "job #{job.id} didn't fit"
      log_potential_carryover    
    end
  end

  def find_best_fit_machine(job)
    case @find_best_fit_machine_strategy.to_sym
    # Use the first fit algorithim (i.e. the first machine we find that's available to take the job)
    # This algorithm is faster (I believe n log n, or something like it)
    when :first_fit
      @available_machines.find {|machine| machine.available_memory >= job.memory_required}
    # This algorithim finds uses the bin packing Best Fit algorithm to find the machine that will have the
    # least capacity remaining after we place it in.  While this algorthm should be more efficient in terms of 
    # machines used, it takes more computational comlpexity (n^2).
    # I was actually surprised to find only minimal cost improvements by using this algorithm, 
    # and wouldn't recommend it
    when :best_fit
      @available_machines
        .select {|machine| machine.available_memory >= job.memory_required }
        .min {|machine| machine.available_memory }
    # My research suggested there are superior algorithms that could be placed here
    # but I'm not sure how much gain you would actually get (based on my experience with best_fit)
    # and they're significantly more complicated to implement
    else 
      raise 'strategy not found'
    end
  end 
end
