# frozen_string_literal: true

puts __FILE__

require 'socket'
require_relative 'response'

module Reactor
  READ = []
  WRITE = []
  ERROR = []

  NoCallbackError = Class.new(IOError)

  module IO
    def _reactor_callback
      raise(NoCallbackError, inspect)
    end
  end

  ::IO.include(IO)

  module TCPSocket
    MAXLEN = 16_384

    def _reactor_callback
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
    def _reactor_callback
      Reactor::READ << accept_nonblock
    end
  end

  ::TCPServer.include(TCPServer)

  def self.call
    trap('INT') { return }
    loop { ::IO.select(READ, WRITE, ERROR).flatten.each(&:_reactor_callback) }
  end
end
