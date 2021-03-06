require './server_accessor.rb'
require './job.rb'
Dir["./strategies/*.rb"].each {|file| require file }
require 'debugger'

class GameRunner
  attr_accessor :server
  def initialize(params)
    @server = ServerAccessor.new
    @params = params
    
    # These variables are only for data analysis purposes
    @total_jobs_seen = 0
    @all_jobs = []
  end

  # Start the game!
  def run
    start_game(@params[:long])
    # Jobs carried over between rounds
    leftover_jobs = []

    while(status != 'completed')
      #pass our jobs carried over between rounds to the next round
      leftover_jobs = run_turn(leftover_jobs)
    end
    # output_final_result
    # Return the game info hash for analysis
    game_info
  end

  def output_final_result
    # How much of each machine's capacity did we end up using?  This is the main indicator
    # of how effective an assignment algorithm is at controlling costs 
    efficiences = assignment_strategy.retired_machines.map(&:efficiency)
    average_efficiency =
      efficiences.inject{ |sum, el| sum + el }.to_f / efficiences.size

    completed_game_info = game_info
    puts "\n\n"
    puts "COMPLETED GAME WITH:"
    puts "Total delay: #{completed_game_info['delay_turns']} turns"
    puts "Total cost: $#{completed_game_info['cost']}"
    puts "Average Efficiency: #{average_efficiency}"
    puts "Efficiencies: #{efficiences}"
    total_time_units = 0
    @all_jobs.each do |job|
      total_time_units += (job.memory_required * job.turns_required)
    end
    puts "total_time_units: #{total_time_units}"
    min_cost = total_time_units.to_f / 64
    # This represents a lower floor of how good any job assignment can be, though unless you have perfect input
    # this floor could not actually be reached
    puts "min cost: #{min_cost}"
  end


  def run_turn(leftover_jobs=[])
    advance_turn
    # Get new jobs from the server
    new_jobs = fetch_jobs
    @all_jobs += new_jobs

    log_turn
    leftover_jobs = assign_jobs(new_jobs + leftover_jobs)
    leftover_jobs
  end

  def fetch_jobs
    current_turn_info['jobs'].map do |job_info|
      Job.new(job_info['id'], job_info['memory_required'], job_info['turns_required'])
    end
  end

  def assign_jobs(new_jobs)
    assignment_strategy.assign_jobs(new_jobs)
  end

  def start_game(long=false)
    server.start_game(long)
  end

  def current_turn_info
    server.current_turn_info
  end

  def advance_turn
    server.advance_turn
  end

  def game_info
    server.get_game_info
  end

  def status
    current_turn_info && current_turn_info['status']
  end

  def assignment_strategy
    # This case statement allows for different job assignment strategies to be used
    # At the current state of development, the ConfigurableStrategy is always better than the alternatives
    # However, having this logic was useful during development, and could be useful again,
    # particularly to implement other assignment strategies fundamentally different from that used in the
    # ConfigurableStrategy
    return(@assignment_strategy) if defined?(@assignment_strategy)
    strategy = 'configurable'
    @assignment_strategy ||=
      case strategy
      when 'single'
        SingleMachineStrategy.new(server, {})
      when 'always_create_new'
        AlwaysMakeNewMachineStrategy.new(server, {})
      when 'configurable'
        ConfigurableStrategy.new(server, @params)
      else
        raise 'strategy not found'
      end
  end

  def log_turn
    # if (current_turn_info['current_turn'] % 25 == 0)
      puts "On turn #{current_turn_info['current_turn']}, got #{current_turn_info['jobs'].count} jobs, having completed #{current_turn_info['jobs_completed']} of #{@all_jobs.length} with #{current_turn_info['jobs_running']} jobs running, #{current_turn_info['jobs_queued']} jobs queued, and #{current_turn_info['machines_running']} machines running"
    # end
  end
end