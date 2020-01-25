# frozen_string_literal: true

puts __FILE__

# require 'fiber'
require 'socket'

require_relative 'io'
require_relative 'tcp_server'
require_relative 'tcp_socket'

require_relative 'reactor'
require_relative 'response'

class Service
  def initialize
    trap('INT') do
      puts 'Shutting down...'
      exit
    end

    Reactor::READ << TCPServer.new(ENV.fetch('HOST'), ENV.fetch('PORT'))
    puts "Listening at http://#{ENV.fetch('HOST')}:#{ENV.fetch('PORT')}!"
    STDOUT.flush
    Reactor.call
  end
end
