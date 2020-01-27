# frozen_string_literal: true

module Flump
  class Middleware
    HTTP_METHODS = %w[
      CONNECT
      DELETE
      GET
      HEAD
      OPTIONS
      PATCH
      POST
      PUT
      TRACE
    ].freeze

    RESPONSE =
      "HTTP/1.1 %<status_code>s %<reason_phrase>s\r\n" \
      "Connection: close\r\n" \
      "Date: %<date>s\r\n" \
      "%<content>s"

    CONTENT =
      "Content-Type: text/html; charset=utf-8\r\n" \
      "Content-Length: %<content_length>s\r\n" \
      "\r\n" \
      "%<content>s"

    def initialize(request)
      headers, @content = request.split("\r\n\r\n")
      headers = headers.split("\r\n")
      @method, @path, @version = headers.shift.split
      headers = headers.map { _1.split(': ') }.to_h
      @content = "\r\n"
      @date = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      @status_code, @reason_phrase = status_code_with_reason_phrase
    end

    def to_s
      format(
        RESPONSE,
        status_code: @status_code,
        reason_phrase: @reason_phrase,
        date: @date,
        content: @content
      )
    end

    private

    def status_code_with_reason_phrase
      case
      when bad_request? then [400, 'Bad Request']
      when version_not_supported? then [505, 'HTTP Version Not Supported']
      when not_found? then [404, 'Not Found']
      else
        # index = format(INDEX, time: Time.now.utc)
        # @content = format(CONTENT, content_length: index.length, content: index)
        @content = ''
        [200, 'OK']
      end
    rescue
      [500, 'Internal Server Error']
    end

    def bad_request?
      [@method, @path, @version].any?(&:nil?) || !HTTP_METHODS.include?(@method)
    end

    def version_not_supported?
      @version != 'HTTP/1.1'
    end

    def not_found?
      @path != '/'
    end
  end
end
