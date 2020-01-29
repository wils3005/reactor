# frozen_string_literal: true

module Flump
  module Request
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

    HTTP_VERSION = 'HTTP/1.1'
    NOT_IMPLEMENTED = %w[CONNECT OPTIONS TRACE].freeze
    MAX_PAYLOAD_SIZE = 16_384

    private

    # @headers, @body, @request, @request_line, @method, @path, @version
    def deserialize_request!
      return if defined? @headers

      @headers, @body = @request.split("\r\n\r\n")
      @headers = @headers.split("\r\n")
      @request_line = @headers.shift.split
      @method, @path, @version = @request_line
      @headers = @headers.map { _1.split(': ') }.to_h
      nil
    end

    def payload_too_large?
      @request.size > MAX_PAYLOAD_SIZE
    end

    def bad_request?
      @request_line.any?(&:nil?) || !HTTP_METHODS.include?(@method)
    end

    def version_not_supported?
      @version != HTTP_VERSION
    end

    def not_implemented?
      NOT_IMPLEMENTED.include?(@method)
    end
  end
end
