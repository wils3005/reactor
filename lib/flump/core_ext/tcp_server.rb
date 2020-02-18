# frozen_string_literal: true

require 'fiber'
require_relative '../http/client'

module Flump
  module TCPServer
    def resume
      Fiber.new { HTTP::Client.new(accept_nonblock).call }.resume
    rescue ::IO::EAGAINWaitReadable
    end

    def wait_readable!
      WAIT_READABLE.push(self)
    end

    ::TCPServer.include(self)
  end
end
