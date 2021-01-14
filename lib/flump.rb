# frozen_string_literal: true

require 'logger'
require 'socket'
require_relative 'flump/exchange'
require_relative 'flump/io'
require_relative 'flump/tcp_server'

module Flump
  VERSION = '0.1.0'

  @logger = Logger.new($stdout)

  class << self
    attr_reader :app, :host, :logger, :options, :port

    def call(app, **options)
      @app = app
      @options = options
      @host = ENV.fetch('HOST', 'localhost')
      @port = ENV.fetch('PORT', '65432')
      @server = TCPServer.new(@host, @port)
      @exchange = Flump::Exchange.new(@app)
      @server.exchange = @exchange
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
