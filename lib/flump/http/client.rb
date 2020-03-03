# frozen_string_literal: true

module Flump
  module HTTP
    class Client
      def initialize(socket)
        @socket = socket
      end

      def call
        env = RequestDeserializer.call(@socket.read_async)
        response_params = Flump.app.call(env)
        raw_response = ResponseSerializer.call(*response_params)
        @socket.write_async(raw_response)
        @socket.close
      rescue EOFError, Errno::ECONNRESET
        @socket.close
      end
    end
  end
end
