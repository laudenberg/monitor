#!/usr/bin/env ruby

require 'json'

if ARGV.count < 1
  puts "please specify config.json"
  exit -1
end

open ARGV[0] do |f|
  arguments = []
  config = JSON.parse(f.read)

  config['aggregates'].each do |aggregate|
    
    aggregate['fields'].each do |field|
      argument = "-#{field['title']}"

      if field['argument']
        argument += " \\\"#{field['argument']}\\\""
      end

      arguments << argument
    end

  end

  if config['alerts']
    alerts = config['alerts'].map{|a| if a.nil? then 'NULL' else a end}.join(' ')
    arguments << "-alert \\\"#{alerts}\\\""
  end

  arguments << "-config \\\"#{File.absolute_path(ARGV[0])}\\\""

  puts arguments.join(' ')
end
