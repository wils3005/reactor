# frozen_string_literal: true

module Flump
  module ResponseSerializer
    def self.call(status_code, headers, rack_body)
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

    def self.default_headers
      {
        'Server' => 'Flump',
        'Date' => Time.now.utc.strftime(HTTP_DATE),
        'Connection' => 'close'
      }
    end
  end
end
