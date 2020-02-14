# frozen_string_literal: true

require 'fiber'
require 'socket'

require_relative 'flump/core_ext/binding'
require_relative 'flump/core_ext/io'
require_relative 'flump/core_ext/pg_connection'
require_relative 'flump/core_ext/tcp_server'

require_relative 'flump/application'
require_relative 'flump/http_connection'
require_relative 'flump/http_request'
require_relative 'flump/http_response'
require_relative 'flump/ws_connection'

module Flump
  CONTENT_TYPE_HTML = 'text/html; charset=utf-8'
  CONTENT_TYPE_JSON = 'application/json; charset=utf-8'

  WAIT_READABLE = []
  WAIT_WRITABLE = []

  def self.async
    Fiber.new { yield }.resume
  end

  def self.listen_async(host, port)
    server = ::TCPServer.new(host, port)
    WAIT_READABLE.push(server)
    warn("Listening at http://#{host}:#{port}!")
    server
  end

  def self.run
    loop { select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume) }
  end
end
