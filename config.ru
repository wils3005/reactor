# frozen_string_literal: true

require 'pry'
require 'rack/handler/flump'


index_html = File.read('index.html')

body = format(
  index_html,
  title: 'flump!',
  host: ENV.fetch('HOST'),
  port: ENV.fetch('PORT')
)

# app = lambda do |env|
#   if env['HTTP_CONNECTION'] == 'Upgrade' && env['HTTP_UPGRADE'] == 'websocket'
#     ws_key = env.fetch('HTTP_SEC-WEBSOCKET-KEY') do
#       return [400, {}, []]
#     end

#     websocket_magic_uuid = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

#     ws_accept =
#       Digest::SHA1.base64digest("#{ws_key}#{websocket_magic_uuid}")

#     headers = {
#       'Upgrade' => 'websocket',
#       'Connection' => 'Upgrade',
#       'Sec-WebSocket-Accept' => ws_accept
#     }

#     return [101, headers, []]
#   end

#   [200, {}, [body]]
# end

app = lambda do |env|

  [200, {}, [body]]
end

Rack::Handler::Flump.run(
  app,
  host: ENV.fetch('HOST'),
  port: ENV.fetch('PORT')
)
