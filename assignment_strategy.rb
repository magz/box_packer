require './server_accessor.rb'
require './machine.rb'


class AssignmentStrategy
  attr_accessor :server, :machines


  def intialize(server)
    @server = server
  end

  def create_machine
    Machine.new(server)
  end

  def current_turn
    server.current_turn
  end

  #shared method to destroy all machines not currently doing work, both on the server and locally
  def destroy_unused_machines
    @available_machines.select(&:deleteable?).each do |machine|
    puts "DESTROYING MACHINE: #{machine.id}"
    retired_machines.push @available_machines.delete(machine)
    machine.destroy!
  end
end