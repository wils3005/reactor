# frozen_string_literal: true

require 'digest/sha1'

module Flump
  class Application
    ROUTES = Hash.new([]).merge!(
      'DELETE' => [],
      'GET' => [],
      'HEAD' => [],
      'OPTIONS' => [],
      'PATCH' => [],
      'POST' => [],
      'PUT' => []
    ).freeze

    WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    ROUTES.keys.each do |http_method|
      Flump.define_singleton_method(http_method.downcase) do |route, &block|
        route = /\A#{route}\z/ if route.is_a?(String)
        route.define_singleton_method(:call, &block)
        # Flump::Application.define_method(route)
        ROUTES[http_method].push(route)
      end
    end

    attr_reader :request,
                :response

    def initialize(request)
      @request = request
      @response = _response
    end

    private

    def _response
      if @request.nil?
        HTTPResponse.new(status_code: 400)
      elsif @request.version >= 2.0
        HTTPResponse.new(status_code: 505)
      elsif !ROUTES.keys.include?(@request.method)
        HTTPResponse.new(status_code: 405)
      elsif @request.headers['Connection'] == 'Upgrade' && @request.headers['Upgrade'] == 'websocket'
        ws_key = @request.headers.fetch('Sec-WebSocket-Key')

        ws_accept =
          Digest::SHA1.base64digest("#{ws_key}#{WEBSOCKET_MAGIC_UUID}")

        headers = {
          'Upgrade' => 'websocket',
          'Connection' => 'Upgrade',
          'Sec-WebSocket-Accept' => ws_accept
        }

        HTTPResponse.new(status_code: 101, headers: headers)
      else
        _route
      end
    rescue => error
      binding.stderr
      HTTPResponse.new(status_code: 500)
    end

    def _route
      ROUTES[@request.method].find { @request.path =~ _1 }&.call ||
        HTTPResponse.new(status_code: 404)
    end
  end
end
