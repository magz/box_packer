require 'rubygems'
require 'bundler/setup'
require 'debugger'

require './game_runner.rb'

# This is just some code I'm leaving in the repo to show how I ran some testing to figure out
# an idea of what parameters to the configurable strategy produced best results


params_to_test = []

[1, 15, 24, 25, 26, 30, 35, 50].each do |acceptable_cost_ratio|
	[:best_fit, :first_fit].each do |find_best_fit_machine_strategy|
		params_to_test.push({acceptable_cost_ratio: acceptable_cost_ratio, 
			find_best_fit_machine_strategy: find_best_fit_machine_strategy}
		)
	end
end

results = 
	params_to_test.map do |params|
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts params
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		result = GameRunner.new(params).run
		[params, result]
	end



results.each do |result|
	puts result.first
	puts result.last
	puts "=========="
end
