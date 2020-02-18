# frozen_string_literal: true

require_relative '../core_ext/io'
require_relative '../ws/client'
require_relative 'exchange'
require_relative 'request'

module Flump
  module HTTP
    class Client
      def initialize(tcp_socket)
        @tcp_socket = tcp_socket
      end

      def call
        raw_request = @tcp_socket.read_async
        request = Request.parse(raw_request)
        response = Exchange.new(request).response
        @tcp_socket.write_async(response)
        return WS::Client.new(@tcp_socket).call if response.status_code == 101

        @tcp_socket.close
      rescue EOFError, Errno::ECONNRESET => error
        binding.stderr
        @tcp_socket.close
      end
    end
  end
end
