# frozen_string_literal: true

require 'fiber'
require 'socket'

module Flump
  module IO
    MAXLEN = 16_384

    def resume
      @fiber.resume
    end

    def read_async(int = MAXLEN)
      chunk = read_nonblock(int)
      return chunk if chunk.length < MAXLEN

      chunk += read_async
    rescue ::IO::WaitReadable
      Flump::Selector.wait_readable(self) do
        @fiber = Fiber.current
        Fiber.yield
      end

      retry
    end

    def write_async(str)
      write_nonblock(str)
    rescue ::IO::WaitWritable
      Flump::Selector.wait_writable(self) do
        @fiber = Fiber.current
        Fiber.yield
      end

      retry
    end

    ::IO.include(self)
  end
end
