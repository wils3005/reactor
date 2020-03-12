# frozen_string_literal: true

module Flump
  module HTTP
    class Client
      def initialize(socket)
        @socket = socket
      end

      def call
        env = RequestDeserializer.call(@socket.read_async)
        # response_params = Flump.app.call(env)
        raw_response = ResponseSerializer.call(*_response_params)
        @socket.write_async(raw_response)
        return WS::Client.new(@socket).call if response_params[0] == 101

        @socket.close
      rescue EOFError, Errno::ECONNRESET
        @socket.close
      end

      private

      def _response_params
        if _bad_request? then [400, {}, []]
        elsif _http_version_not_supported? then [505, {}, []]
        elsif _method_not_allowed? then [405, {}, []]
        elsif _switching_protocols? then _switching_protocols
        else [404, {}, []]
        end
      rescue => error
        [500, {}, []]
      end

      ##########################################################################

      # def _bad_request?
      #   env['REQUEST_METHOD'].empty? ||
      #     @request.path.empty? ||
      #     @request.version < 1.0 ||
      #     !@request.headers.key?('Host')
      # end

      # def _http_version_not_supported?
      #   @request.version >= 2.0
      # end

      # def _method_not_allowed?
      #   !ALLOWED_METHODS.include?(@request.method)
      # end

      def _switching_protocols?
        @env['HTTP_CONNECTION'] == 'Upgrade' &&
          @env['HTTP_UPGRADE'] == 'websocket'
      end

      def _switching_protocols
        ws_key = env.fetch('HTTP_SEC-WEBSOCKET-KEY') do
          return [400, {}, []]
        end

        ws_accept =
          Digest::SHA1.base64digest("#{ws_key}#{WEBSOCKET_MAGIC_UUID}")

        headers = {
          'Upgrade' => 'websocket',
          'Connection' => 'Upgrade',
          'Sec-WebSocket-Accept' => ws_accept
        }

        { status_code: 101, headers: headers }
      end
    end
  end
end
