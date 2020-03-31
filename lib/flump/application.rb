# frozen_string_literal: true

require 'digest/sha1'
require 'erb'

module Flump
  class Application
    INTERNAL = /(localhost)|(127\.0\.0\.\d+)|(192\.168\.0\.\d+)/.freeze
    WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    def initialize
      @css = File.read('app.css')
      js = File.read('app.js.erb')
      @js = ERB.new(js)
      html = File.read('index.html.erb')
      @html = ERB.new(html)
    end

    def call(env)
      ws_key = env['HTTP_SEC-WEBSOCKET-KEY']
      ws_accept = Digest::SHA1.base64digest("#{ws_key}#{WEBSOCKET_MAGIC_UUID}")

      ws_headers = {
        'Upgrade' => 'websocket',
        'Connection' => 'upgrade',
        'Sec-WebSocket-Accept' => ws_accept
      }

      ws_upgrade =
        env['HTTP_CONNECTION'] =~ /upgrade/i &&
        env['HTTP_UPGRADE'] == 'websocket'

      return [101, ws_headers, []] if ws_upgrade

      internal = (env['HTTP_X-FORWARDED-FOR'] || env['SERVER_NAME']) =~ INTERNAL
      js = @js.result_with_hash(ws_url: 'wss://wils.ca/flump')
      content = @html.result_with_hash(title: '#flump', css: @css, js: js)
      [200, { 'Connection' => 'close' }, [content]]
    rescue => @error
      warn(inspect)
      [500, {}, []]
    end
  end
end
