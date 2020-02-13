# frozen_string_literal: true

module Flump
  module HTTP
    class Request
      ParsingError = Class.new(RuntimeError)

      def self.parse(str)
        headers, body = str.split("\r\n\r\n")
        headers = headers.split("\r\n")
        request_line = headers.shift.split
        method, path, version = request_line
        path, query = path.split('?')
        query = query.nil? ? {} : query.split('&').map { _1.split('=') }.to_h
        headers = headers.map { _1.split(': ') }.to_h

        new(
          host: headers['Host'],
          method: method,
          path: path,
          query: query,
          version: version,
          headers: headers,
          body: body
        )
      rescue => @error
        raise(ParsingError, inspect)
      end

      attr_reader :host,
                  :method,
                  :path,
                  :query,
                  :version,
                  :headers,
                  :body,
                  :to_s

      def initialize(host:, method:, path:, **options)
        @host = host
        @method = method
        @path = path
        @query = options[:query] || {}
        @version = options[:version] || 'HTTP/1.1'
        @headers = options[:headers] || {}
        @body = options[:body] || ''
        @to_s = _to_s
      end

      def no_content?
        @path == '/siege'
      end

      def bad_request?
        @method.nil? ||
          @path.nil? ||
          @version.nil? ||
          !METHODS.include?(@method)
      end

      def http_version_not_supported?
        @version != VERSION
      end

      def switching_protocols?
        @headers.websocket_upgrade?
      end

      private

      def _to_s
        headers = _default_headers.merge(@headers).http_headers

        "#{@method} #{@path} #{@version}\r\n" \
        "#{headers}\r\n" \
        "\r\n" \
        "#{@body}"
      end

      def _default_headers
        {
          'Host' => @host,
          'User-Agent' => 'flump/0.1.0',
          'Accept' => '*/*',
          'Connection' => 'keep-alive'
        }
      end
    end
  end
end
