# frozen_string_literal: true

module Flump
  module HTTP
    class Client
      def initialize(socket)
        @socket = socket
        warn(inspect)
      end

      def read_write
        env = RequestDeserializer.call(@socket)
        status_code, response_headers, response_body = Flump.app.call(env)

        ResponseSerializer.call(
          @socket,
          status_code,
          response_headers,
          response_body
        )

        case response_headers['Connection']
        when 'close' then @socket.close
        when 'upgrade' then WS::Connection.new(@socket).read
        else @socket.close
        end
      rescue EOFError, Errno::ECONNRESET => @error
        warn(inspect)
        @socket.close
      end
    end
  end
end
