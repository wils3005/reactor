# frozen_string_literal: true

require 'digest/sha1'
require_relative '../core_ext/binding'
require_relative 'response'

module Flump
  module HTTP
    class Exchange
      ALLOWED_METHODS = %w[GET HEAD].freeze
      WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

      attr_reader :request, :response

      def initialize(request)
        @request = request
        @response = Response.new(**_response_args)
      end

      private

      def _response_args
        if _bad_request? then { status_code: 400 }
        elsif _http_version_not_supported? then { status_code: 505 }
        elsif _method_not_allowed? then { status_code: 405 }
        elsif _switching_protocols? then _switching_protocols
        elsif _route then _route.call
        else { status_code: 404 }
        end
      rescue => error
        binding.stderr
        { status_code: 500 }
      end

      ##########################################################################

      def _bad_request?
        @request.method.empty? ||
          @request.path.empty? ||
          @request.version < 1.0 ||
          !@request.headers.key?('Host')
      end

      def _http_version_not_supported?
        @request.version >= 2.0
      end

      def _method_not_allowed?
        !ALLOWED_METHODS.include?(@request.method)
      end

      def _switching_protocols?
        @request.headers['Connection'] == 'Upgrade' &&
          @request.headers['Upgrade'] == 'websocket'
      end

      def _switching_protocols
        ws_key = @request.headers.fetch('Sec-WebSocket-Key') do
          return { status_code: 400 }
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

      def _route
        ->{ { status_code: 204 } }
      end
    end
  end
end
