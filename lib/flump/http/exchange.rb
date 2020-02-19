# frozen_string_literal: true

require 'digest/sha1'
require_relative 'response'

module Flump
  module HTTP
    class Exchange
      EXCHANGES = {
        'DELETE' => [],
        'GET' => [],
        'HEAD' => [],
        'PATCH' => [],
        'POST' => [],
        'PUT' => []
      }.freeze

      WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

      def self.call(request)
        params =
          if request.method.empty? || request.path.empty? || request.version < 1.0 || !request.headers.key?('Host')
            { status_code: 400 }
          elsif request.version >= 2.0
            { status_code: 505 }
          elsif !EXCHANGES.keys.include?(request.method)
            { status_code: 405 }
          elsif request.headers['Connection'] == 'Upgrade' && request.headers['Upgrade'] == 'websocket'
            ws_key = request.headers.fetch('Sec-WebSocket-Key') do
              { status_code: 400 }
            end

            ws_accept =
              Digest::SHA1.base64digest("#{ws_key}#{WEBSOCKET_MAGIC_UUID}")

            headers = {
              'Upgrade' => 'websocket',
              'Connection' => 'Upgrade',
              'Sec-WebSocket-Accept' => ws_accept
            }

            { status_code: 101, headers: headers }
          else
            EXCHANGES[request.method].
              find { |exchange| request.path =~ exchange.path }&.
              call(request) ||
              { status_code: 404 }
          end

        Response.new(**params)
      rescue
        Response.new(status_code: 500)
      end

      attr_reader :path

      def initialize(method, path, &block)
        @path = path.is_a?(String) ? %r{\A#{path}\z} : path
        define_singleton_method(:call, &block)
        EXCHANGES[method.to_s.upcase] << self
      end
    end
  end
end
