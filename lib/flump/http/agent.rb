# frozen_string_literal: true

require 'socket'

module Flump
  module HTTP
    class Agent
      def initialize(host:, port: 80)
        @host = host
        @port = port
        @tcp_socket = TCPSocket.new(host, port)
      end

      def call(method:, path:, query: {}, headers: {}, body: '')
        request = RequestSerializer.call(
          method: method,
          host: @host,
          path: path,
          query: query,
          headers: headers,
          body: body
        )

        @tcp_socket.write_async(request)
        response = ResponseDeserializer.call(@tcp_socket.read_async)
        @tcp_socket.close
        response
      end
    end
  end
end
