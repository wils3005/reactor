# frozen_string_literal: true

module Flump
  module TCPServer
    def resume
      Fiber.new { accept_nonblock.read_write }.resume
    rescue ::IO::EAGAINWaitReadable
    end

    def wait_readable
      WAIT_READABLE.push(self)
    end

    ::TCPServer.include(self)
  end
end
