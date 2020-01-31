# frozen_string_literal: true

module Flump
  module Reactor
    module TCPServer
      module ClassMethods
        def listen_async
          server = new(HOST, PORT)
          READ << server
          server
        end
      end

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      def resume
        Fiber.new { accept_nonblock.read_request_and_write_response }.resume
      rescue ::IO::EAGAINWaitReadable
      end
    end
  end
end
