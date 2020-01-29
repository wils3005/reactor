# frozen_string_literal: true

module Flump
  module Response
    RESPONSE_TEMPLATE =
      "HTTP/1.1 %<status_code>s %<reason_phrase>s\r\n" \
      "Connection: close\r\n" \
      "Date: %<date>s\r\n" \
      "%<content>s"

    CONTENT_TEMPLATE =
      "Content-Type: text/html; charset=utf-8\r\n" \
      "Content-Length: %<content_length>s\r\n" \
      "\r\n" \
      "%<content>s"

    private

    def serialize_response!
      return if defined? @content

      @content = "\r\n"
      @date = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      @status_code, @reason_phrase = status_code_with_reason_phrase

      @response = format(
        RESPONSE_TEMPLATE,
        status_code: @status_code,
        reason_phrase: @reason_phrase,
        date: @date,
        content: @content
      )
      nil
    end

    def status_code_with_reason_phrase
      case
      when payload_too_large? then [413, 'Payload Too Large']
      when bad_request? then [400, 'Bad Request']
      when version_not_supported? then [505, 'HTTP Version Not Supported']
      when not_implemented? then [501, 'Not Implemented']
      else
        content = Router.call(@method, @path)
        return [404, 'Not Found'] if content.nil?

        @content = format(
          CONTENT_TEMPLATE,
          content_length: content.size,
          content: content
        )

        [200, 'OK']
      end
    rescue => e
      STDERR.write_nonblock("#{Process.pid} #{inspect} #{e.inspect}\n")
      [500, 'Internal Server Error']
    end
  end
end
