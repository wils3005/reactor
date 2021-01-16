# frozen_string_literal: true

require 'logger'

module Flump
  class Configuration
    attr_reader :app, :options, :exchange, :host, :logger, :port, :server

    def initialize(app, **options)
      @app = app
      @options = options

      @host = options.fetch(:host, ENV.fetch('HOST', 'localhost'))
      @port = options.fetch(:port, ENV.fetch('PORT', '9292'))
      @logger = options.fetch(:logger, Logger.new($stdout))

      @exchange = HTTPExchange.new(@host, @port)
      @server = TCPServer.new(@host, @port)
      @server.block = -> { @exchange.call(_1, &@app.method(:call)) }
      @server.wait_readable
    end
  end
end
