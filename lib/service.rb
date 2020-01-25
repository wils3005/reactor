# frozen_string_literal: true

puts __FILE__

require 'socket'

require_relative 'reactor'
require_relative 'response'
require_relative 'server'
require_relative 'reactor/accept'
require_relative 'reactor/request'
require_relative 'reactor/response'

class Service
  def initialize
    trap('INT') do
      puts 'Shutting down...'
      exit
    end

    Server.new
    STDOUT.flush
    IO.reactor
  end
end
