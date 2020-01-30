# frozen_string_literal: true

module Flump
  NoCallbackError = Class.new(RuntimeError)

  DSL_ENABLED = true

  MASTER_PID = Process.pid
  NUM_PROCESSES = 1

  MAXLEN = 16_384

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
  MAX_PAYLOAD_SIZE = 16_384

  HTTP_VERSION_NOT_SUPPORTED = [505, 'HTTP Version Not Supported'].freeze
  INTERNAL_SERVER_ERROR = [500, 'Internal Server Error'].freeze
  PAYLOAD_TOO_LARGE = [413, 'Payload Too Large'].freeze
  NOT_FOUND = [404, 'Not Found'].freeze
  BAD_REQUEST = [400, 'Bad Request'].freeze
  OK = [200, 'OK'].freeze

  RESPONSE =
    "HTTP/1.1 %<status_code>s %<reason_phrase>s\r\n" \
    "Connection: close\r\n" \
    "Date: %<date>s\r\n" \
    "%<content>s"

  CONTENT =
    "Content-Type: text/html; charset=utf-8\r\n" \
    "Content-Length: %<content_length>s\r\n" \
    "\r\n" \
    "%<content>s"
end
