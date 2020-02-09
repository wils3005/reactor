# frozen_string_literal: true

module Flump
  class HTTPRequest
    attr_reader :body,
                :headers,
                :method,
                :path,
                :query,
                :raw,
                :request_line,
                :response,
                :version

    def initialize(raw)
      @raw = raw
      @headers, @body = raw.split("\r\n\r\n")
      @headers = @headers.split("\r\n")
      @request_line = @headers.shift.split
      @method, @path, @version = @request_line
      @path, @query = @path.split('?')
      @query = @query.nil? ? {} : @query.split('&').map { _1.split('=') }.to_h
      @headers = @headers.map { _1.split(': ') }.to_h
      @response = HTTPResponse.new(**_response_params)
    end

    private

    def _response_params
      if @path == '/siege'
        { status_code: 204 }
      elsif @request_line.any?(&:nil?) || !HTTP_METHODS.include?(@method)
        { status_code: 400 }
      elsif @version != HTTP_VERSION
        { status_code: 505 }
      elsif @headers['Connection'] == 'Upgrade' && @headers['Upgrade'] == 'websocket'
        {
          status_code: 101,
          headers: {
            'Upgrade' => 'websocket',
            'Connection' => 'Upgrade',
            'Sec-WebSocket-Accept' => _sec_websocket_accept
          }
        }
      else
        { status_code: 200, **Index.call }
      end
    rescue => @error
      warn(inspect)
      { status_code: 500 }
    end

    def _sec_websocket_accept
      str = @headers['Sec-WebSocket-Key']
      "#{str}258EAFA5-E914-47DA-95CA-C5AB0DC85B11".base64digest
    end
  end
end
