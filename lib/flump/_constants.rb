# frozen_string_literal: true

module Flump
  APP_FILES =
    Dir.glob(File.join(Dir.pwd, 'app', '**', '*.rb')).freeze

  DBNAME = ::ENV.fetch('DBNAME')
  HOST = ::ENV.fetch('HOST')
  NUM_PROCESSES = ::ENV.fetch('NUM_PROCESSES').to_i
  PORT = ::ENV.fetch('PORT')

  WAIT_READABLE = []
  WAIT_WRITABLE = []

  MASTER_PID = Process.pid
  MAX_PAYLOAD_SIZE = 16_384
  VERSION = '0.1.0'
  WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

  HTTP_METHODS = [
    'CONNECT',
    'DELETE',
    'GET',
    'HEAD',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
    'TRACE'
  ].freeze

  REASON_PHRASE = {
    101 => 'Switching Protocols',
    200 => 'OK',
    201 => 'Created',
    204 => 'No Content',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Not Found',
    413 => 'Payload Too Large',
    414 => 'URI Too Long',
    415 => 'Unsupported Media Type',
    422 => 'Unprocessable Entity',
    426 => 'Upgrade Required',
    429 => 'Too Many Requests',
    431 => 'Request Header Fields Too Large',
    500 => 'Internal Server Error',
    505 => 'HTTP Version Not Supported'
  }.freeze

  HTTP_VERSION = 'HTTP/1.1'

  CONTENT_TYPE_HTML = 'text/html; charset=utf-8'
  CONTENT_TYPE_JSON = 'application/json; charset=utf-8'
end
