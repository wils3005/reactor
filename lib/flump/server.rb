# frozen_string_literal: true

module Flump
  module Server
    def resume
      ::Fiber.new do
        io = accept_nonblock
        ::Fiber.current.io = io
        io.read_write_async
      end.resume
    rescue ::IO::WaitReadable
    end

    TCPServer.include(self)
    UNIXServer.include(self)
  end
end
