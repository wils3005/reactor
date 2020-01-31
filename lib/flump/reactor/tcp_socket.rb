# frozen_string_literal: true

module Flump
  module Reactor
    module TCPSocket
      def foo
        @fiber = Fiber.current
        READ << self
        Fiber.yield
        @request = read_nonblock(MAXLEN)
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
      rescue EOFError
      ensure
        READ.delete(self)
        @fiber = nil
      end

      def resume
        @fiber.resume
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
        INTERNAL_SERVER_ERROR
      end
    end
  end
end

# def server_request_async
#   fibers << Fiber.new do
#     @request = read_nonblock(MAXLEN)
#     write_nonblock(@response)
#     close
#   rescue ::IO::EAGAINWaitReadable => @error
#     stderr
#     server_request_async
#   rescue => @error
#     stderr
#   ensure
#     READ.delete(self)
#     fibers.delete(Fiber.current)
#   end

#   READ << self
# end

# def client_request_async(req)
#   fibers << Fiber.new do
#     write_nonblock(req)
#     Fiber.yield
#     @res = read_nonblock(MAXLEN)
#     close
#   rescue ::IO::EAGAINWaitWritable => @error
#     stderr
#   rescue => @error
#     stderr
#   ensure
#     WRITE.delete(self)
#     fibers.delete(Fiber.current)
#   end

#   WRITE << self
# end
