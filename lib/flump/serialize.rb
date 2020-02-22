# frozen_string_literal: true

module Flump
  module Serialize
    HTTP_DATE = '%a, %d %b %Y %H:%M:%S GMT'

    REASON_PHRASES = {
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

    def serialize(status_code, headers, rack_body)
      headers =
        default_headers.
        merge(headers).
        map { |k, v| "#{k}: #{v}" }.
        join("\r\n")

      body = ''
      rack_body.each { |it| body += it }

      "HTTP/1.1 #{status_code} #{REASON_PHRASES[status_code]}\r\n" \
      "#{headers}\r\n" \
      "\r\n" \
      "#{body}"
    end

    private

    def default_headers
      {
        'Server' => 'Flump',
        'Date' => Time.now.utc.strftime(HTTP_DATE),
        'Connection' => 'close'
      }
    end
  end
end
