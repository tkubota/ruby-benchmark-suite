#!/usr/bin/env ruby
#
# adapted from http://www.shelldorado.com/scripts/cmds/timeout

prog = File.dirname(__FILE__) + "/timeout.rb"
prog_name  = File.basename(prog)		# Program name
version = 0.1
time_out = 10				# Set default [seconds]

if ARGV.length == 0
	puts "#{prog_name} - set timeout for a command, version #{version}"
	puts "Usage: #{prog_name} [-t timeout] command [argument ...]"
	puts "-t: timeout (in seconds, default is #{time_out})"
	exit 0
end

if ARGV.first == '-t'
	ARGV.shift
	time_out = ARGV.first
	ARGV.shift
end

if ARGV.first == '-p'
	ARGV.shift
	parent_pid = ARGV.first
	ARGV.shift
end

if parent_pid
	# Sleep and then kill our parent process
	puts "DEBUG: Sleep for #{time_out} seconds and then kill pid #{parent_pid}"
	sleep time_out.to_i
	puts "DEBUG: Finished sleeping"        
	begin
		Process.kill(:TERM, parent_pid.to_i)
		puts "DEBUG: Tried kill -TERM"
		sleep 2
        	Process.kill(:HUP, parent_pid.to_i)
		puts "DEBUG: Tried kill -HUP"
		sleep 2
        	Process.kill(:KILL, parent_pid.to_i)
		puts "DEBUG: Tried kill -KILL"
	rescue Errno::ESRCH => e
		puts "DEBUG: rescue #{e.class}: #{e.message}"
		nil
	end
else
	# Start "watchdog" process, and then run the command.
	watchdog = "#{prog} -t #{time_out} -p #{$$} &"
	puts "DEBUG: Watchdog invocation is #{watchdog}"
	puts "DEBUG: Start watchdog process to kill pid #{$$} and then run:"
        puts "DEBUG: #{ARGV.join(' ')}"
	system("#{watchdog}")			# Start watchdog
	exec "#{ARGV.join(' ')}"		# Run requested command
	puts "DEBUG: Oops! We shouldn't get past the exec command"
	exit 2                                  # NOT REACHED
end