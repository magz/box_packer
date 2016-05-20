require 'rubygems'
require 'bundler/setup'
require 'debugger'

require './server_accessor.rb'
require './game_runner.rb'


acceptable_cost_ratio = (ARGV[0] || 24).to_i
find_best_fit_machine_strategy = (ARGV[1] || 'first_fit').to_sym

params = {acceptable_cost_ratio: acceptable_cost_ratio, 
	find_best_fit_machine_strategy: find_best_fit_machine_strategy}


result = GameRunner.new(params).run

puts result.first
puts result.last
puts "=========="














