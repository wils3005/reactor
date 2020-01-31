# frozen_string_literal: true

module Flump
  module Reactor
    module TCPSocket
      def read_request_and_write_response
        @fiber = Fiber.current
        READ << self
        Fiber.yield
        @request = read_nonblock(MAXLEN)
        READ.delete(self)
        @headers, @body = @request.split("\r\n\r\n")
        @headers = @headers.split("\r\n")
        @request_line = @headers.shift.split
        @method, @path, @version = @request_line
        @headers = @headers.map { _1.split(': ') }.to_h
        @content = "\r\n"
        @status_code, @reason_phrase = status_code_with_reason_phrase

        @response = format(
          RESPONSE,
          status_code: @status_code,
          reason_phrase: @reason_phrase,
          date: ::Time.date_header,
          content: @content
        )

        write_nonblock(@response)
        close
      rescue ::IO::EAGAINWaitReadable, ::IO::EAGAINWaitWritable, EOFError => @error
        READ.delete(self)
        ::STDERR.write_async("#{inspect} #{@error.inspect}")
      ensure
        @fiber = nil
      end

      def write_request_and_read_response
        @fiber = Fiber.current
        WRITE << self
        Fiber.yield
        write_nonblock(REQUEST)
        WRITE.delete(self)
        READ << self
        Fiber.yield
        @response = read_nonblock(MAXLEN)
        READ.delete(self)
        close
        @response
      rescue ::IO::EAGAINWaitReadable, ::IO::EAGAINWaitWritable, EOFError => @error
        READ.delete(self)
        WRITE.delete(self)
        ::STDERR.write_async("#{inspect} #{@error.inspect}")
      ensure
        @fiber = nil
      end

      def resume
        @fiber.resume
      rescue NoMethodError
        raise(NoFiberError, inspect)
      end

      private

      def status_code_with_reason_phrase
        return PAYLOAD_TOO_LARGE if @request.size > MAX_PAYLOAD_SIZE
        return BAD_REQUEST if @request_line.any?(&:nil?) || !HTTP_METHODS.include?(@method)
        return HTTP_VERSION_NOT_SUPPORTED if @version != HTTP_VERSION

        @body = Router.call(@method, @path)
        return NOT_FOUND if @body.nil?

        @content = format(
          CONTENT,
          content_length: @body.length,
          content: @body
        )

        OK
      rescue => @error
        ::STDERR.write_async("#{inspect} #{@error.inspect}")
        INTERNAL_SERVER_ERROR
      end
    end
  end
end
