# frozen_string_literal: true

module Flump
  module HTTP
    class Connection
      def initialize(tcp_socket)
        @tcp_socket = tcp_socket
      end

      def read_write
        raw_request = @tcp_socket.read_async
        request = Request.parse(raw_request)
        response = App.new(request).response
        @tcp_socket.write_async(response)
        return WS::Connection.new(@tcp_socket).read_write if response.status_code == 101

        @tcp_socket.close
      rescue EOFError, Errno::ECONNRESET
        @tcp_socket.close
      end

      def write_read(host:, method:, path:, **options)
        request = Request.new(
          host: host,
          method: method,
          path: path,
          **options
        )

        raw_response = @tcp_socket.write_async(request)
        response = Response.parse(raw_response)
        @tcp_socket.close
        response
      end
    end
  end
end
