#!/usr/bin/env ruby -w
# simple_client.rb
# A simple DRb client

require 'drb'

DRb.start_service

drb_url = ARGV.shift
unless drb_url
  raise "first arg should be a Drb url, like: druby://localhost:65147"
end

command = ARGV.shift
unless command
  raise "second arg exptected to be a command, either 'debug' or 'resume' "
end

thing = DRbObject.new nil, drb_url

if command == "debug"
  dest_path = ARGV.shift
  unless dest_path
    raise "no destination path given (expected as 3rd arg)"
  end
  puts "going to write trace to: #{dest_path}"
  result = thing.run(dest_path)
  puts result
elsif command == "resume"
  puts "stopping trace"
  result = thing.stop
  puts result
else
  raise "unknown command #{command}"
end