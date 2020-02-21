# frozen_string_literal: true

module Flump
  module TCPSocket
    def resume
      @fiber.resume
    end

    def read_write
      env = RequestDeserializer.call(read_async)
      version = env['HTTP_VERSION'].split('/').last.to_f

      bad_request =
        env['REQUEST_METHOD'].empty? ||
        env['PATH_INFO'].empty? ||
        version < 1.0 ||
        !env.key?('HTTP_HOST')

      response_params =
        if bad_request
          [400, {}, []]
        elsif version >= 2.0
          [505, {}, []]
        elsif !ALLOWED_METHODS.include?(env['REQUEST_METHOD'])
          [405, {}, []]
        else
          Flump.app.call(env)
        end

      raw_response = ResponseSerializer.call(*response_params)
     write_async(raw_response)
     close
    rescue EOFError, Errno::ECONNRESET
     close
    end

    def read_async(int = 16_384)
      read_nonblock(int)
    rescue ::IO::EAGAINWaitReadable
      wait_readable
      retry
    end

    def write_async(str)
      write_nonblock(str)
    rescue ::IO::EAGAINWaitWritable
      wait_writable
      retry
    end

    def wait_readable
      WAIT_READABLE.push(self)
      @fiber = Fiber.current
      Fiber.yield
      WAIT_READABLE.delete(self)
    end

    def wait_writable
      WAIT_WRITABLE.push(self)
      @fiber = Fiber.current
      Fiber.yield
      WAIT_WRITABLE.delete(self)
    end

    ::TCPSocket.include(self)
  end
end
