# frozen_string_literal: true

require 'fiber'
require 'socket'

module Flump
  module TCPServer
    def resume
      Fiber.new { HTTP::Connection.new(accept_nonblock).read_write }.resume
    rescue ::IO::EAGAINWaitReadable
      # A forked process can result in socket readiness false positives
    end
  end

  ::TCPServer.include(TCPServer)
end
