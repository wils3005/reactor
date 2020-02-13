# frozen_string_literal: true

module Flump
  module HTTP
    class Response
      ParsingError = Class.new(RuntimeError)

      def self.parse(str)
        headers, body = str.split("\r\n\r\n")
        headers = headers.split("\r\n")
        status_line = headers.shift.split
        version, status_code, reason_phrase = status_line
        headers = headers.map { _1.split(': ') }.to_h

        new(
          version: version,
          status_code: status_code,
          headers: headers,
          body: body
        )
      rescue => @error
        raise(ParsingError, inspect)
      end

      attr_reader :version,
                  :status_code,
                  :reason_phrase,
                  :headers,
                  :body,
                  :to_s

      def initialize(status_code:, **options)
        @version = options[:version] || 'HTTP/1.1'
        @status_code = status_code
        @reason_phrase = REASON_PHRASE[status_code]
        @headers = options[:headers] || {}
        @body = options[:body] || ''
        @to_s = _to_s
      end

      private

      def _to_s
        headers = _default_headers.merge(@headers).http_headers

        "#{@version} #{@status_code} #{@reason_phrase}\r\n" \
        "#{headers}\r\n" \
        "\r\n" \
        "#{@body}"
      end

      def _default_headers
        { 'Date' => ::Time.http_date, 'Server' => 'Flump' }
      end
    end
  end
end
