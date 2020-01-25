# frozen_string_literal: true

puts __FILE__

require 'socket'

require_relative 'io'
require_relative 'reactor'
require_relative 'response'
require_relative 'server'

class App
  def initialize
    trap('INT') do
      puts 'Shutting down...'
      exit
    end

    reactor = Reactor.new
    Server.new(reactor)
    reactor.call
  end
end

# status = 200
# headers = { 'Content-Type' => 'text/plain' }
# body = ['']

# [status, headers, body]
