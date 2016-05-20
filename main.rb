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


puts params
puts result
puts "=========="




# {:acceptable_cost_ratio=>1, :find_best_fit_machine_strategy=>:first_fit}
# {"id"=>16036, "cost"=>515, "current_turn"=>57, "completed"=>true, "created_at"=>"2016-05-20T03:11:09.000Z", "updated_at"=>"2016-05-20T03:12:41.000Z", "jobs_completed"=>492, "total_score"=>192.0, "cost_score"=>92.0, "time_score"=>100.0, "short"=>true, "delay_turns"=>0}










