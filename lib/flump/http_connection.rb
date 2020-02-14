# frozen_string_literal: true

module Flump
  class HTTPConnection
    def self.write_read(host:, port: 80, method:, path:, **options)
      tcp_socket = TCPSocket.new(host, port)

      new(tcp_socket).write_read(
        host: host,
        port: port,
        method: method,
        path: path,
        options: options
      )
    end

    def initialize(tcp_socket)
      @tcp_socket = tcp_socket
    end

    def read_write
      raw_request = @tcp_socket.read_async
      request = HTTPRequest.parse(raw_request)
      response = Application.new(request).response
      @tcp_socket.write_async(response)
      return WSConnection.new(@tcp_socket).read_write if response.status_code == 101

      @tcp_socket.close
    rescue EOFError, Errno::ECONNRESET
      @tcp_socket.close
    end

    def write_read(host:, port: 80, method:, path:, headers: {}, body: '')
      request = HTTPRequest.new(
        host: host,
        method: method,
        path: path,
        headers: headers,
        body: body
      )

      @tcp_socket.write_async(request)
      raw_response = @tcp_socket.read_async
      response = HTTPResponse.parse(raw_response)
      @tcp_socket.close
      response
    end
  end
end
