# frozen_string_literal: true

puts __FILE__

require 'socket'
require_relative 'response'

module Reactor
  READ = []
  WRITE = []
  ERROR = []

  module TCPSocket
    MAXLEN = 16_384

    def call
      write_nonblock(Response.new(read_nonblock(MAXLEN)))
      close
    rescue IOError => e
      puts(e.inspect)
    ensure
      Reactor::READ.delete(self)
    end
  end

  ::TCPSocket.include(TCPSocket)

  module TCPServer
    def call
      Reactor::READ << accept_nonblock
    end
  end

  ::TCPServer.include(TCPServer)

  def self.call
    loop { IO.select(READ, WRITE, ERROR).flatten.each(&:call) }
  end
end
