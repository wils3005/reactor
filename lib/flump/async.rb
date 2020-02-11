# frozen_string_literal: true

module Flump
  module Async
    NoFiberError = Class.new(NoMethodError)

    WAIT_READABLE = []
    WAIT_WRITABLE = []

    def self.run
      loop { select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume) }
    end

    def read_async(int = 16_384)
      read_nonblock(int)
    rescue ::IO::EAGAINWaitReadable
      WAIT_READABLE.push_delete(self, &method(:_yield_fiber))
      retry
    end

    def write_async(str)
      write_nonblock(str)
    rescue ::IO::EAGAINWaitWritable
      WAIT_WRITABLE.push_delete(self, &method(:_yield_fiber))
      retry
    end

    def resume
      @fiber.resume
    rescue NoMethodError
      raise(NoFiberError, inspect)
    end

    private

    def _yield_fiber
      @fiber = Fiber.current
      Fiber.yield
    end
  end

  ::IO.include(Async)
end
