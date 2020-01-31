# frozen_string_literal: true

module Flump
  module Reactor
    module STDERR
      def write_async(str)
        fibers << Fiber.new do
          write_nonblock(str)
        rescue ::IO::EAGAINWaitWritable
          write_async(str)
        ensure
          WRITE.delete(self)
          fibers.delete(Fiber.current)
        end

        WRITE << self
      end

      def resume
        fibers.each(&:resume)
      end

      private

      def fibers
        @fibers ||= []
      end
    end
  end
end
