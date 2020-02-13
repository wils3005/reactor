# frozen_string_literal: true

module Flump
  module HTTP
    class App
      attr_reader :request,
                  :response

      def initialize(request)
        @request = request
        @status_code, @headers, @body = _status_code_headers_body
        @response = _response
      end

      private

      def _response
        Response.new(
          status_code: @status_code,
          headers: @headers,
          body: @body
        )
      end

      def _status_code_headers_body
        if @request.no_content?
          [204, {}, '']
        elsif @request.bad_request?
          [400, {}, '']
        elsif @request.http_version_not_supported?
          [505, {}, '']
        elsif @request.switching_protocols?
          headers = {
            'Upgrade' => 'websocket',
            'Connection' => 'Upgrade',
            'Sec-WebSocket-Accept' => @request.headers.sec_websocket_accept
          }

          [101, headers, '']
        else
          route = Router.call(@request.method, @request.path)
          route || [404, { 'Connection' => 'close' }, '']
        end
      rescue => @error
        warn(inspect)
        [500, {}, '']
      end
    end
  end
end
