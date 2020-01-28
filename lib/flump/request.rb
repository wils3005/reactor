# frozen_string_literal: true

module Flump
  module Request
    METHODS = %w[
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

    MAX_PAYLOAD_SIZE = 4_096

    def deserialize_request!
      return if defined? @headers

      @headers, @body = @request.split("\r\n\r\n")
      @headers = @headers.split("\r\n")
      @method, @path, @version = @headers.shift.split
      @headers = @headers.map { _1.split(': ') }.to_h
    end

    def bad_request?
      [@method, @path, @version].any?(&:nil?) || !METHODS.include?(@method)
    end

    def version_not_supported?
      @version != 'HTTP/1.1'
    end

    def not_implemented?
      %w[CONNECT OPTIONS TRACE].include?(@method)
    end

    def payload_too_large?
      @request.size > MAX_PAYLOAD_SIZE
    end
  end
end
