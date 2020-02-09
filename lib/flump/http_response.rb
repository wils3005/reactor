# frozen_string_literal: true

module Flump
  class HTTPResponse
    attr_reader :status_code,
                :headers,
                :body,
                :raw

    def initialize(status_code: 200, headers: {}, body: '')
      @status_code = status_code
      @reason_phrase = REASON_PHRASE[status_code]
      @headers = _default_headers.merge(headers)
      @body = body
      @raw = _raw
    end

    private

    def _default_headers
      { 'Date' => ::Time.http_date, 'Server' => 'Flump' }
    end

    def _raw
      "HTTP/1.1 #{@status_code} #{@reason_phrase}\r\n" \
      "#{@headers.http_headers}\r\n" \
      "#{@body.http_content}"
    end
  end
end
