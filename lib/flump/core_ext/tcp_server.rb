# frozen_string_literal: true

require 'fiber'
require_relative '../http_connection'

module Flump
  module TCPServer
    def resume
      Fiber.new { HTTPConnection.new(accept_nonblock).read_write }.resume
    rescue ::IO::EAGAINWaitReadable
    end

    def wait_readable!
      WAIT_READABLE.push(self)
    end

    ::TCPServer.include(self)
  end
end
