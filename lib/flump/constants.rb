# frozen_string_literal: true

module Flump
  NoFiberError = Class.new(RuntimeError)

  BAD_REQUEST = [400, 'Bad Request'].freeze

  CONTENT =
    "Content-Type: text/html; charset=utf-8\r\n" \
    "Content-Length: %<content_length>s\r\n" \
    "\r\n" \
    "%<content>s"

  HOST = ENV.fetch('HOST')

  HTTP_VERSION_NOT_SUPPORTED = [505, 'HTTP Version Not Supported'].freeze

  HTTP_METHODS = %w[
    CONNECT
    DELETE
    GET
    HEAD
    OPTIONS
    PATCH
    POST
    PUT
    TRACE
  ].freeze

  HTTP_VERSION = 'HTTP/1.1'

  INTERNAL_SERVER_ERROR = [500, 'Internal Server Error'].freeze

  MASTER_PID = Process.pid

  MAXLEN = 16_384

  NUM_PROCESSES = ENV.fetch('NUM_PROCESSES').to_i

  NOT_FOUND = [404, 'Not Found'].freeze

  MAX_PAYLOAD_SIZE = 16_384

  OK = [200, 'OK'].freeze

  PAYLOAD_TOO_LARGE = [413, 'Payload Too Large'].freeze

  PORT = ENV.fetch('PORT')

  REQUEST = "GET / HTTP/1.1\r\n\r\n"

  RESPONSE =
    "HTTP/1.1 %<status_code>s %<reason_phrase>s\r\n" \
    "Connection: close\r\n" \
    "Date: %<date>s\r\n" \
    "%<content>s"
end
