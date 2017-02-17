#!/usr/bin/env ruby

require 'json'

open ARGV[2] do |f|
  config = JSON.parse(f.read)
  fields = {}
  titles = {}
  field_i = 1

  config['aggregates'].each do |aggregate|

    aggregate['fields'].each do |field|
      argument = field['title']

      if field['argument']
        argument += " \\\"#{field['argument']}\\\""
      end

      fields[field_i] = argument
      titles[field_i] = aggregate['title']
      field_i += 1
    end

  end

  mailto = config['alertmailto']
  `echo "ALERT: #{titles[ARGV[0].to_i]} #{fields[ARGV[0].to_i]}  #{ARGV[1]}" | mailx -s "ALERT: #{titles[ARGV[0].to_i]} #{fields[ARGV[0].to_i]} #{ARGV[1]}" #{config['alertmailto']}`
end

