# frozen_string_literal: true

module Flump
  class HTTPExchange
    attr_reader :method,
                :path,
                :query,
                :raw_request,
                :raw_response,
                :request_body,
                :request_headers,
                :request_line,
                :response_body,
                :response_headers,
                :status_code,
                :version

    def initialize(raw_request)
      @raw_request = raw_request
      @request_headers, @request_body = raw_request.split("\r\n\r\n")
      @request_headers = @request_headers.split("\r\n")
      @request_line = @request_headers.shift.split
      @method, @path, @version = @request_line
      @path, @query = @path.split('?')
      @query = @query.nil? ? {} : @query.split('&').map { _1.split('=') }.to_h
      @request_headers = @request_headers.map { _1.split(': ') }.to_h

      @status_code, @response_headers, @response_body = _response
      @raw_response = _raw_response
    end

    private

    def _raw_response
      "HTTP/1.1 #{@status_code} #{REASON_PHRASE[@status_code]}\r\n" \
      "#{_default_response_headers.merge(@response_headers).http_headers}\r\n" \
      "#{@response_body.http_content}"
    end

    def _response
      if @path == '/siege'
        [204, {}, '']
      elsif @request_line.any?(&:nil?) || !HTTP_METHODS.include?(@method)
        [400, {}, '']
      elsif @version != HTTP_VERSION
        [505, {}, '']
      elsif @request_headers.websocket_upgrade?
        headers = {
          'Upgrade' => 'websocket',
          'Connection' => 'Upgrade',
          'Sec-WebSocket-Accept' => @request_headers.sec_websocket_accept
        }

        [101, headers, '']
      else
        Router.call(@method, @path)
      end
    rescue => @error
      print_error
      [500, {}, '']
    end

    def _default_response_headers
      { 'Date' => ::Time.http_date, 'Server' => 'Flump' }
    end
  end
end
