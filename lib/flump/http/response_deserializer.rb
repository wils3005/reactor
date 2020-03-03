# frozen_string_literal: true

module Flump
  module HTTP
    module ResponseDeserialier
      def self.call(raw_response)
        response_line_and_headers, body = raw_response.split("\r\n\r\n")
        response_line_and_headers = response_line_and_headers.split("\r\n")
        body = body.to_s

        _version, status_code, reason_phrase =
          response_line_and_headers.shift.split

        headers = response_line_and_headers.each do |str|
          k,v = str.split(': ')
          env["HTTP_#{k.upcase}"] = v
        end

        {
          status_code: status_code,
          reason_phrase: reason_phrase,
          headers: headers,
          body: body
        }
      end
    end
  end
end
