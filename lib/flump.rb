# frozen_string_literal: true

require 'digest/sha1'
require 'socket'
require_relative 'flump/application'
require_relative 'flump/http'
require_relative 'flump/ws'
require_relative 'flump/io'

module Flump
  ::IO.include(IO)

  VERSION = '0.1.0'

  @pid = Process.pid
  @wait_readable = []
  @wait_writable = []

  class << self
    attr_reader :app,
                :host,
                :port,
                :tcp_server,
                :http_server,
                :wait_readable,
                :wait_writable

    def call(app, **options)
      @app = app
      @host = options[:host] || ENV.fetch('HOST') { 'localhost' }
      @port = options[:port] || ENV.fetch('PORT') { 65432 }
      @tcp_server = TCPServer.new(@host, @port)
      @http_server = Flump::HTTP::Server.new(@tcp_server)
      warn "#{@pid}/flump listening at http://#{@host}:#{@port}!"

      trap 'INT' do
        warn "\nShutting down...\n"
        exit
      end

      loop do
        select(@wait_readable, @wait_writable).flatten.each(&:resume)
      end
    end
  end
end
