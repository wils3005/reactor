# frozen_string_literal: true

require 'logger'
require 'socket'
require_relative 'flump/io'
require_relative 'flump/tcp_server'
require_relative 'flump/tcp_socket'

module Flump
  VERSION = '0.1.0'

  @logger = Logger.new(STDOUT)
  @wait_readable = []
  @wait_writable = []

  class << self
    attr_reader :logger, :wait_readable, :wait_writable

    def call
      @pid = Process.pid
      @host = ENV.fetch('HOST', 'localhost')
      @port = ENV.fetch('PORT', 65_432)
      @wait_readable << TCPServer.new(@host, @port)
      @logger.info("#{@pid}/flump listening at http://#{@host}:#{@port}!")
      trap('INT', &method(:shutdown))
      loop(&method(:resume))
    end

    def resume
      select(@wait_readable, @wait_writable).flatten.each(&:resume)
    end

    def shutdown(*)
      warn "\nShutting down...\n"
      exit
    end
  end
end
