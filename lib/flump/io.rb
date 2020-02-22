# frozen_string_literal: true

module Flump
  module IO
    def resume
      @fiber.resume
    end

    def read_async(int = 16_384)
      read_nonblock(int)
    rescue ::IO::EAGAINWaitReadable
      wait_readable
      retry
    end

    def write_async(str)
      write_nonblock(str)
    rescue ::IO::EAGAINWaitWritable
      wait_writable
      retry
    end

    def wait_readable
      Flump.wait_readable.push(self)
      @fiber = Fiber.current
      Fiber.yield
      Flump.wait_readable.delete(self)
    end

    def wait_writable
      Flump.wait_writable.push(self)
      @fiber = Fiber.current
      Fiber.yield
      Flump.wait_writable.delete(self)
    end

    ::IO.include(self)
  end
end
