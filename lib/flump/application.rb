# frozen_string_literal: true

module Flump
  class Application
    WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    def initialize
      @index = File.read('index.html')
      warn(inspect)
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
        if env['SERVER_NAME'] =~ /192\.168\.0\.\d+/ || env['HTTP_X-FORWARDED-FOR'] =~ /192\.168\.0\.\d+/
          "ws://#{Flump.host}:#{Flump.port}/flump"
        else
          'wss://wils.ca/flump'
        end

      body = format(
        @index,
        title: '#flump',
        websocket_url: websocket_url
      )

      [200, { 'Connection' => 'close' }, [body]]
    rescue => @error
      warn(inspect)
      [500, {}, []]
    end
  end
end
