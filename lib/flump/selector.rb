# frozen_string_literal: true

module Flump
  module Selector
    @wait_readable = []
    @wait_writable = []

    def self.run
      Thread.new do
        loop do
          select(@wait_readable, @wait_writable).flatten.each(&:resume)
        end
      end
    end

    def self.wait_readable(io)
      @wait_readable << io

      if block_given?
        yield
        @wait_readable.delete(io)
      end
    end

    def self.wait_writable(io)
      @wait_writable << io

      if block_given?
        yield
        @wait_writable.delete(io)
      end
    end
  end
end
