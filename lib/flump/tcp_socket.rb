# frozen_string_literal: true

module Flump
  module TCPSocket
    def call
      @request ||= read_nonblock(MAXLEN)
      Reactor::READ.delete(self)
      deserialize_request!
      serialize_response!
      write_nonblock(@response)
      Reactor::WRITE.delete(self)
      close
    rescue ::IO::EAGAINWaitReadable => @error
      stderr
    rescue ::IO::EAGAINWaitWritable => @error
      stderr
      Reactor::WRITE << self
    rescue IOError => @error
      stderr
      Reactor::READ.delete(self)
      Reactor::WRITE.delete(self)
    end

    private

    def deserialize_request!
      return if defined? @headers

      @headers, @body = @request.split("\r\n\r\n")
      @headers = @headers.split("\r\n")
      @request_line = @headers.shift.split
      @method, @path, @version = @request_line
      @headers = @headers.map { _1.split(': ') }.to_h
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

    def serialize_response!
      return if defined? @content

      @content = "\r\n"
      @date = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      @status_code, @reason_phrase = status_code_with_reason_phrase

      @response = format(
        RESPONSE,
        status_code: @status_code,
        reason_phrase: @reason_phrase,
        date: @date,
        content: @content
      )
    end

    ############################################################################

    def status_code_with_reason_phrase
      return PAYLOAD_TOO_LARGE if payload_too_large?
      return BAD_REQUEST if bad_request?
      return HTTP_VERSION_NOT_SUPPORTED if version_not_supported?

      content = Router.call(@method, @path)
      return NOT_FOUND if content.nil?

      @content = format(
        CONTENT,
        content_length: content.length,
        content: content
      )

      OK
    rescue => @error
      stderr
      INTERNAL_SERVER_ERROR
    end
  end
end
