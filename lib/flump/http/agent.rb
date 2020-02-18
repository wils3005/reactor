# frozen_string_literal: true

require_relative '../core_ext/io'
require_relative 'request'
require_relative 'response'

module Flump
  module HTTP
    class Agent
      def initialize(host:, port: 80)
        @host = host
        @port = port
        @tcp_socket = TCPSocket.new(host, port)
      end

      def call(method:, path:, headers: {}, body: '')
        request = Request.new(
          host: @host,
          method: method,
          path: path,
          headers: headers,
          body: body
        )

        @tcp_socket.write_async(request)
        raw_response = @tcp_socket.read_async
        response = Response.parse(raw_response)
        @tcp_socket.close
        response
      end
    end
  end
end
