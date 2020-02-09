# frozen_string_literal: true

module Flump
  module Async
    attr_accessor :fiber

    def resume
      fiber.resume
    end

    private

    def _async
      yield
    rescue ::IO::EAGAINWaitReadable
      READ.push_delete(self, &_yield_fiber)
      retry
    rescue ::IO::EAGAINWaitWritable
      WRITE.push_delete(self, &_yield_fiber)
      retry
    end

    def _yield_fiber
      lambda do
        self.fiber = Fiber.current
        Fiber.yield
        self.fiber = nil
      end
    end
  end
end
