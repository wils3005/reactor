# frozen_string_literal: true

module Flump
  module HTTP
    class Agent
      def initialize(host, port)
        @host = host
        @port = port
        @tcp_socket = TCPSocket.new(host, port)
        warn(inspect)
      end

      def write_read(method:, path:, query: {}, headers: {}, body: '')
        serialized_headers =
          { 'Host' => @host }.
          merge(headers).
          map { |k, v| "#{k}: #{v}" }.
          join("\r\n")

        serialized_query =
          query.any? ?
          query.map { |k, v| "#{k}=#{v}" }.join('&').prepend('?') :
          ''

        raw_request =
          "#{method.to_s.upcase} #{path}#{serialized_query} HTTP/1.1\r\n" \
          "#{serialized_headers}\r\n" \
          "\r\n" \
          "#{body}"

        @tcp_socket.write_async(raw_request)
        raw_response = @tcp_socket.read_async
        response_line_and_headers, response_body = raw_response.split("\r\n\r\n")
        response_line_and_headers = response_line_and_headers.split("\r\n")
        response_body = response_body.to_s

        _version, status_code, reason_phrase =
          response_line_and_headers.shift.split

        response_headers = response_line_and_headers.each do |str|
          k,v = str.split(': ')
          env["HTTP_#{k.upcase}"] = v
        end

        response = {
          status_code: status_code,
          reason_phrase: reason_phrase,
          headers: response_headers,
          body: body
        }

        @tcp_socket.close if response_headers['HTTP_CONNECTION'] == 'close'
        response
      end
    end
  end
end
