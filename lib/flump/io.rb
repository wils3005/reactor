# frozen_string_literal: true

require 'fiber'

module Flump
  module IO
    NoFiberError = Class.new(NoMethodError)

    def resume
      @fiber.resume
    rescue NoMethodError
      raise(NoFiberError, inspect)
    end

    def read_async(int = 16_384)
      read_nonblock(int)
    rescue ::IO::EAGAINWaitReadable
      wait_readable!
      retry
    end

    def write_async(str)
      write_nonblock(str)
    rescue ::IO::EAGAINWaitWritable
      wait_writable!
      retry
    end

    def wait_readable!
      WAIT_READABLE.push(self)
      @fiber = Fiber.current
      Fiber.yield
      WAIT_READABLE.delete(self)
    end

    def wait_writable!
      WAIT_WRITABLE.push(self)
      @fiber = Fiber.current
      Fiber.yield
      WAIT_WRITABLE.delete(self)
    end
  end

  ::IO.include(IO)
end
