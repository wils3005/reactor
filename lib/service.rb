# frozen_string_literal: true

puts __FILE__

require 'socket'
require_relative 'reactor'

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
