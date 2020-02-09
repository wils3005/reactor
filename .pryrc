# frozen_string_literal: true

require 'objspace'

require_relative 'lib/flump'
Thread.new { Flump.call }

# Pry.config.commands.command 'asdf' do |*args|
#   warn args.inspect
# end
