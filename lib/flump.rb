# frozen_string_literal: true

require 'fiber'
require 'socket'

require_relative 'flump/api'
require_relative 'flump/io'
require_relative 'flump/server'
require_relative 'flump/socket'

module Flump
  @host = ENV.fetch('HOST')
  @port = ENV.fetch('PORT')
  @pid = Process.pid
  @pg_connections = ENV.fetch('PG_CONNECTIONS').to_i
  @num_processes = ENV.fetch('NUM_PROCESSES') { 1 }.to_i
  @wait_readable = []
  @wait_writable = []

  class << self
    attr_accessor :app,
                  :host,
                  :pg_pool,
                  :port,
                  :pid,
                  :num_processes

    attr_reader :wait_readable,
                :wait_writable,
                :pg_pool

    def call
      @wait_readable << TCPServer.new(@host, @port)
      @pg_pool = Array.new(@pg_connections) { PG::Connection.new(dbname: 'flump') }

      warn("Flump listening at http://#{@host}:#{@port}!")

      trap 'INT' do
        warn "\nShutting down...\n"
        exit
      end

      (@num_processes - 1).times { Process.fork if Process.pid == @pid }
      loop { select(@wait_readable, @wait_writable).flatten.each(&:resume) }
    end
  end
end
