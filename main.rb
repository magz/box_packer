require 'rubygems'
require 'bundler/setup'
require 'debugger'

require './server_accessor.rb'
require './game_runner.rb'


server = ServerAccessor.new
GameRunner.new(server).run
# server.start_game
# machine = Machine.new(server.create_machine['id'])

# server.advance_turn
# turn = server.current_turn_info
# jobs_found = turn['jobs'].count

# status = server.current_turn_info['status']

# while (status != 'completed')
#   turn = server.current_turn_info
#   puts "On turn #{turn['current_turn']}, got #{turn['jobs'].count} jobs, having completed #{turn['jobs_completed']} of #{jobs_found} with #{turn['jobs_running']} jobs running, #{turn['jobs_queued']} jobs queued, and #{turn['machines_running']} machines running"

#   new_jobs =
#     server.current_turn_info['jobs'].map do |job_info|
#       Job.new(job_info['id'], job_info['memory_required'], job_info['turns_required'])
#     end


#   new_jobs.each do |job|
#     machine.assign_job(job)
#     machine.finalize_assignment!
#   end

#   server.advance_turn
#   turn = server.current_turn_info

#   jobs_found += turn['jobs'].count

#   status = server.current_turn_info['status']
# end



def cleanup_machines
  machines.select {|m| m.totally_free? }.each {|m| server.destroy_machine(m)}
end



















