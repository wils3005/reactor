# frozen_string_literal: true

require 'fiber'
require 'socket'

require_relative 'flump/api'
require_relative 'flump/fiber'
require_relative 'flump/io'
require_relative 'flump/pg_connection'
require_relative 'flump/server'
require_relative 'flump/socket'

module Flump
  @pid = Process.pid
  @wait_readable = []
  @wait_writable = []

  class << self
    attr_accessor :app,
                  :host,
                  :pg_connection_pool_size,
                  :port,
                  :process_pool_size

    attr_reader :pg_connection_pool,
                :pid,
                :wait_readable,
                :wait_writable

    def call
      @wait_readable << TCPServer.new(@host, @port)
      # @pg_connection_pool = PGConnectionPool.new(pg_connection_pool_size)

      warn("Flump listening at http://#{@host}:#{@port}!")

      trap 'INT' do
        warn "\nShutting down...\n"
        exit
      end

      (process_pool_size - 1).times { Process.fork if Process.pid == @pid }

      loop do
        select(@wait_readable, @wait_writable).flatten.each(&:resume)
      end
    end

    def query(sql)
      PG::Connection.new(dbname: 'flump', port: 5432).query(sql).to_a
    rescue PG::ConnectionBad
      ::Fiber.current.io.wait_writable
      retry
    end
  end
end
