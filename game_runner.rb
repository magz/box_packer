
require './server_accessor.rb'
require './job.rb'
Dir["./strategies/*.rb"].each {|file| require file }

# require './single_machine_strategy.rb'
# require './always_make_new_machine_strategy.rb'
require 'debugger'

class GameRunner
  attr_accessor :server
  def initialize(server)
    @server = server
  end

  def run
    start_game
    while(status != 'completed')
      puts "status: #{status}"
      run_turn
    end
    output_final_result
  end

  def output_final_result
    completed_game_info = server.get_game_info
    puts "\n\n"
    puts "COMPLETED GAME WITH:"
    puts "Total delay: #{completed_game_info['delay_turns']} turns"
    puts "Total cost: $#{completed_game_info['cost']}"
  end

  def run_turn
    advance_turn
    new_jobs = fetch_jobs
    log_turn
    assign_jobs(new_jobs)
  end

  def fetch_jobs
    current_turn_info['jobs'].map do |job_info|
      Job.new(job_info['id'], job_info['memory_required'], job_info['turns_required'])
    end
  end

  def assign_jobs(new_jobs)
    assignment_strategy('always_create_new').assign_jobs(new_jobs)
  end

  def start_game
    server.start_game
  end

  def current_turn_info
    server.current_turn_info
  end

  def advance_turn
    server.advance_turn
  end

  def status
    current_turn_info && current_turn_info['status']
  end

  def assignment_strategy(strategy)
    @assignment_strategy ||=
      case strategy
      when 'single'
        SingleMachineStrategy.new(server)
      when 'always_create_new'
        AlwaysMakeNewMachineStrategy.new(server)
      else
        raise 'strategy not found'
      end
  end

  def log_turn
    puts "On turn #{current_turn_info['current_turn']}, got #{current_turn_info['jobs'].count} jobs, having completed #{current_turn_info['jobs_completed']} of ??? with #{current_turn_info['jobs_running']} jobs running, #{current_turn_info['jobs_queued']} jobs queued, and #{current_turn_info['machines_running']} machines running"
  end
end