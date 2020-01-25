# frozen_string_literal: true

puts __FILE__

require 'socket'

require_relative 'io'
require_relative 'response'
require_relative 'server'

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
