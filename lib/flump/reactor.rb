# frozen_string_literal: true

module Flump
  module Reactor
    READ = []
    WRITE = []

    def self.call
      trap('INT') { return }
      loop { ::IO.select(READ, WRITE).flatten.each(&:call) }
    end

    # def self.wait_readable(io)
    #   io.fiber = Fiber.current
    #   @read << io
    #   Fiber.yield
    #   str = io.read_nonblock
    #   @read.delete(io)
    #   str
    # end

    # def self.wait_writable(io, str)
    #   io.fiber = Fiber.current
    #   @write << io
    #   Fiber.yield
    #   int = io.write_nonblock(str)
    #   WRITE.delete(io)
    #   int
    # end
  end
end
