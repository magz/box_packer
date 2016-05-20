require './server_accessor.rb'
require './machine.rb'


class AssignmentStrategy
  attr_accessor :server, :available_machines, :retired_machines


  def initialize(server, params)
    @server = server
    @params = params
    @available_machines = []
    @retired_machines = []
  end

  def create_machine
    new_machine = Machine.new(server)
    available_machines.push new_machine
    new_machine
  end

  def current_turn
    server.current_turn
  end

  #shared method to destroy all machines not currently doing work, both on the server and locally
  def destroy_unused_machines
    available_machines.select(&:deleteable?).each do |machine|
      retired_machines.push available_machines.delete(machine)
      machine.destroy!
    end
  end
end