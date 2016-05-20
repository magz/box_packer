require 'json'
require 'rest-client'

class ServerAccessor
  attr_accessor :current_turn_info, :game

  def initialize

  end

  def host
    'http://job-queue-dev.elasticbeanstalk.com'
  end

  def start_game
    game_json = RestClient.post(
      "#{host}/games",
      {}
      # { long: true }
    ).body
    @game = JSON.parse(game_json)
  end

  def create_machine
    machine_json = RestClient.post(
      "#{host}/games/#{game['id']}/machines",
      {}
    ).body
    JSON.parse(machine_json)
  end

  def destroy_machine(machine)
    machine_json = RestClient.delete("#{host}/games/#{game['id']}/machines/#{machine.id}")
    JSON.parse(machine_json)
  end

  def assign_jobs(machine, jobs)
    RestClient.post(
      "#{host}/games/#{game['id']}/machines/#{machine.id}/job_assignments",
      job_ids: JSON.dump(jobs.map(&:id))
    ).body
  end

  def advance_turn
    turn_json = RestClient.get(
      "#{host}/games/#{game['id']}/next_turn"
    ).body
    @current_turn_info = JSON.parse(turn_json)
  end

  def current_turn
    current_turn_info['current_turn'].to_i
  end

  def get_game_info
    game_json = RestClient.get("#{host}/games/#{game['id']}",).body

    JSON.parse(game_json)
  end
end