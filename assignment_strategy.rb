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





end