#!/usr/bin/env ruby
# coding: utf-8

controller_args = ARGV.join(' ')
model_args = controller_args.gsub('admin/', '')

system("rails g scaffold_controller #{controller_args}")
system("rails g model #{model_args}")

puts "@@@ DO NOT FORGET TO ADD #{ARGV[1]} TO config/routes @@@"

