# frozen_string_literal: true

require 'digest/sha1'

module Flump
  class App
    WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    attr_reader :request, :response

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
        Flump.route(@request.method, @request.path) ||
          HTTPResponse.new(status_code: 404)
      end
    rescue => @error
      warn(inspect)
      HTTPResponse.new(status_code: 500)
    end
  end
end
