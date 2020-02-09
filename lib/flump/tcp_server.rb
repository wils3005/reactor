# frozen_string_literal: true

module Flump
  module TCPServer
    def resume
      Fiber.new { accept_nonblock.read_write }.resume
    rescue ::IO::EAGAINWaitReadable
      # A forked process can result in socket readiness false positives
    end
  end

  ::TCPServer.include TCPServer
end
