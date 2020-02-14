# frozen_string_literal: true

require 'fiber'
require 'socket'
require_relative 'flump/app'
require_relative 'flump/http_connection'
require_relative 'flump/http_request'
require_relative 'flump/http_response'
require_relative 'flump/io'
require_relative 'flump/pg_connection'
require_relative 'flump/tcp_server'
require_relative 'flump/ws_connection'

module Flump
  CONTENT_TYPE_HTML = 'text/html; charset=utf-8'
  CONTENT_TYPE_JSON = 'application/json; charset=utf-8'

  ROUTES = Hash.new([]).merge!(
    'DELETE' => [],
    'GET' => [],
    'HEAD' => [],
    'OPTIONS' => [],
    'PATCH' => [],
    'POST' => [],
    'PUT' => []
  ).freeze

  WAIT_READABLE = []
  WAIT_WRITABLE = []

  def self.async
    Fiber.new { yield }.resume
  end

  def self.listen_async(host, port)
    server = ::TCPServer.new(host, port)
    server.extend(TCPServer)
    WAIT_READABLE.push(server)
    warn("Listening at http://#{host}:#{port}!")
    server
  end

  def self.route(method, path)
    ROUTES[method].find { path =~ _1 }&.call
  end

  def self.run
    loop { select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume) }
  end

  ROUTES.keys.each do |http_method|
    define_singleton_method(http_method.downcase) do |route, &block|
      route = /\A#{route}\z/ if route.is_a?(String)
      route.define_singleton_method(:call, &block)
      ROUTES[http_method].push(route)
    end
  end
end
