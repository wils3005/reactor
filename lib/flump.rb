# frozen_string_literal: true

require 'forwardable'
require 'socket'

require_relative 'flump/io'
require_relative 'flump/reactor'
require_relative 'flump/request'
require_relative 'flump/response'
require_relative 'flump/tcp_server'
require_relative 'flump/tcp_socket'

::IO.include(Flump::IO)
::TCPServer.include(Flump::TCPServer)
::TCPSocket.include(Flump::TCPSocket)

module Flump
  extend Reactor

  def self.call
    Reactor::READ << ::TCPServer.new(ENV.fetch('HOST'), ENV.fetch('PORT'))
    puts "Listening at http://#{ENV.fetch('HOST')}:#{ENV.fetch('PORT')}!"
    STDOUT.flush
    reactor
    puts 'Shutting down...'
  end
end
