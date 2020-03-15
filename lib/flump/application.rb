# frozen_string_literal: true

module Flump
  class Application
    WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    def initialize
      @index = File.read('index.html')
    end

    def call(env)
      if env['HTTP_CONNECTION'] =~ /upgrade/i && env['HTTP_UPGRADE'] == 'websocket'
        ws_key = env.fetch('HTTP_SEC-WEBSOCKET-KEY') do
          return [400, {}, []]
        end

        ws_accept =
          Digest::SHA1.base64digest("#{ws_key}#{WEBSOCKET_MAGIC_UUID}")

        headers = {
          'Upgrade' => 'websocket',
          'Connection' => 'upgrade',
          'Sec-WebSocket-Accept' => ws_accept
        }

        return [101, headers, []]
      end

      websocket_url =
        if env['flump.ip_address'] =~ /192\.168\.0\.\d+/
          'ws://192.168.0.2:49916'
        else
          'ws://wils.ca:49916'
        end

      body = format(
        @index,
        title: 'flump!',
        websocket_url: websocket_url
      )

      [200, { 'Connection' => 'close' }, [body]]
    rescue => @error
      warn(inspect)
      [500, {}, []]
    end

    private

    # def _response_params
      # if _bad_request? then [400, {}, []]
      # elsif _http_version_not_supported? then [505, {}, []]
      # elsif _method_not_allowed? then [405, {}, []]
      # elsif _switching_protocols? then _switching_protocols
      # else [404, {}, []]
      # end
    # rescue => error
    #   [500, {}, []]
    # end

    ############################################################################

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

    # def _switching_protocols?
    #   @env['HTTP_CONNECTION'] == 'Upgrade' &&
    #     @env['HTTP_UPGRADE'] == 'websocket'
    # end
  end
end
