# frozen_string_literal: true

require 'pry'
require 'logger'
require 'socket'
require_relative 'flump/http_exchange'
require_relative 'flump/io'
require_relative 'flump/tcp_server'

module Flump
  VERSION = '0.1.0'

  @logger = Logger.new($stdout)

  class << self
    attr_reader :app, :logger, :options

    def call(app, **options)
      @app = app
      @options = options
      @host = ENV.fetch('HOST', 'localhost')
      @port = ENV.fetch('PORT', '9292')
      @server = TCPServer.new(@host, @port)
      @exchange = HTTPExchange.new(@host, @port)

      @server.block = lambda do |raw_request|
        @exchange.call(raw_request) do |env|
          @app.call(env)
        end
      end

      IO.wait_readable.push(@server)
      @logger.info("flump listening at http://#{@host}:#{@port}!")

      trap 'INT' do
        warn "\nShutting down...\n"
        exit
      end

      loop(&IO.method(:resume))
    end
  end
end
