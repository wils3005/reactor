# frozen_string_literal: true

require_relative 'deserialize'
require_relative 'serialize'

module Flump
  module Socket
    include Deserialize
    include Serialize

    WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

    def read_write_async
      env = deserialize(read_async)
      response_params = Flump.app.call(env)
      raw_response = serialize(*response_params)
      write_async(raw_response)
      close
    rescue EOFError, Errno::ECONNRESET
      close
    end

    ::TCPSocket.include(self)
    ::UNIXSocket.include(self)
  end
end

# ALLOWED_METHODS = [
#   'DELETE',
#   'GET',
#   'HEAD',
#   'PATCH',
#   'POST',
#   'PUT'
# ].freeze

# version = env['HTTP_VERSION'].split('/').last.to_f

# bad_request =
#   env['REQUEST_METHOD'].empty? ||
#   env['PATH_INFO'].empty? ||
#   version < 1.0 ||
#   !env.key?('HTTP_HOST')

# response_params =
#   if bad_request
#     [400, {}, []]
#   elsif version >= 2.0
#     [505, {}, []]
#   elsif !ALLOWED_METHODS.include?(env['REQUEST_METHOD'])
#     [405, {}, []]
#   else
#     Flump.app.call(env)
#   end
