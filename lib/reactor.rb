# frozen_string_literal: true

puts(__FILE__)

require 'socket'

module Reactor
  class << self
    def register(io:, mode:, handler:)
      io.define_singleton_method(:reactor_handler, &handlers[handler])
      send(mode) << io
    end

    def unregister(io:, mode:)
      send(mode).delete(io)
    end

    def handler(handler_name, &block)
      handlers[handler_name] = block
    end

    def start
      loop { IO.select(read, write).flatten.each(&:reactor_handler) }
    end

    private

    def handlers
      @handlers ||= {}
    end

    def read
      @read ||= []
    end

    def write
      @write ||= []
    end
  end
end
