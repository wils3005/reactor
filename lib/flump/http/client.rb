# frozen_string_literal: true

module Flump
  module HTTP
    class Client
      def initialize(socket)
        @socket = socket
      end

      def call
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
        when 'upgrade' then WS::Client.new(@socket).call
        else @socket.close
        end
      rescue EOFError, Errno::ECONNRESET => e
        warn("#{__FILE__} #{__method__} #{e.inspect}")
        @socket.close
      end
    end
  end
end
