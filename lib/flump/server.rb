# frozen_string_literal: true

module Flump
  module Server
    def resume
      Fiber.new { accept_nonblock.read_write_async }.resume
    rescue ::IO::WaitReadable
    end

    TCPServer.include(self)
    UNIXServer.include(self)
  end
end
