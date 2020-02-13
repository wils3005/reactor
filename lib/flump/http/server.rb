# frozen_string_literal: true

require 'socket'

module Flump
  module HTTP
    class Server
      def initialize
        @tcp_server = ::TCPServer.new(HOST, PORT)
        warn "Listening at http://#{HOST}:#{PORT}!"
      end

      def wait_readable!
        WAIT_READABLE.push(@tcp_server)
      end
    end
  end
end
