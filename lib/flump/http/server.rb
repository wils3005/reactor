# frozen_string_literal: true

require 'fiber'

module Flump
  module HTTP
    class Server
      module Resume
        def resume
          Fiber.new { Client.new(accept_nonblock).call }.resume
        rescue ::IO::WaitReadable
        end
      end

      def initialize(server)
        @server = server
        @server.extend(Resume)
        Flump::Selector.wait_readable(@server)
      end
    end
  end
end
