# frozen_string_literal: true

module Flump
  class HTTPResponse
    REASON_PHRASE = {
      101 => 'Switching Protocols',
      200 => 'OK',
      201 => 'Created',
      204 => 'No Content',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      413 => 'Payload Too Large',
      414 => 'URI Too Long',
      415 => 'Unsupported Media Type',
      422 => 'Unprocessable Entity',
      426 => 'Upgrade Required',
      429 => 'Too Many Requests',
      431 => 'Request Header Fields Too Large',
      500 => 'Internal Server Error',
      505 => 'HTTP Version Not Supported'
    }.freeze

    def self.parse(str)
      status_line_and_headers, body = str.split("\r\n\r\n")
      status_line_and_headers = status_line_and_headers.split("\r\n")
      body = body.to_s
      version, status_code, reason_phrase = status_line_and_headers.shift.split
      version = version.to_s.split('/').last.to_f
      status_code = status_code.to_i
      reason_phrase = reason_phrase.to_s
      headers = status_line_and_headers.map { _1.split(': ') }.to_h
      return if status_code < 100

      new(
        version: version,
        status_code: status_code,
        reason_phrase: reason_phrase,
        headers: headers,
        body: body
      )
    end

    attr_reader :version,
                :status_code,
                :reason_phrase,
                :headers,
                :body,
                :to_s

    def initialize(version: 1.1, status_code:, reason_phrase: nil, headers: {}, body: '')
      @version = version
      @status_code = status_code
      @reason_phrase = reason_phrase || REASON_PHRASE[status_code]
      @headers = headers
      @body = body
      @to_s = _to_s
    end

    private

    def _to_s
      headers =
        _default_headers.
        merge(@headers).
        map { "#{_1}: #{_2}" }.
        join("\r\n")

      "HTTP/#{@version} #{@status_code} #{@reason_phrase}\r\n" \
      "#{headers}\r\n" \
      "\r\n" \
      "#{@body}"
    end

    def _default_headers
      {
        'Server' => 'Flump',
        'Date' => Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      }
    end
  end
end
