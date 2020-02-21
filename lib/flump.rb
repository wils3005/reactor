# frozen_string_literal: true

require 'fiber'
require 'socket'

require_relative 'flump/request_deserializer'
require_relative 'flump/response_serializer'
require_relative 'flump/tcp_server'
require_relative 'flump/tcp_socket'

module Flump
  ALLOWED_METHODS = [
    'DELETE',
    'GET',
    'HEAD',
    'PATCH',
    'POST',
    'PUT'
  ].freeze

  HOST = ENV.fetch('HOST')
  HTTP_DATE = '%a, %d %b %Y %H:%M:%S GMT'
  MASTER_PID = Process.pid
  NULL_IO, = ::IO.pipe
  NUM_PROCESSES = ENV.fetch('NUM_PROCESSES') { 1 }.to_i
  PORT = ENV.fetch('PORT')

  REASON_PHRASES = {
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

  WAIT_READABLE = []
  WAIT_WRITABLE = []
  WEBSOCKET_MAGIC_UUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

  def self.call(app)
    @app = app
    ::TCPServer.new(HOST, PORT).wait_readable

    warn("Flump listening at http://#{HOST}:#{PORT}!")

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    (NUM_PROCESSES - 1).times { Process.fork if Process.pid == MASTER_PID }
    loop { select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume) }
  end

  def self.app
    @app
  end
end
