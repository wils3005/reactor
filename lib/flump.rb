# frozen_string_literal: true

require 'fiber'
require 'socket'

require_relative 'flump/io'
require_relative 'flump/server'
require_relative 'flump/socket'

require_relative 'flump/user'

module Flump
  @host = ENV.fetch('HOST')
  @port = ENV.fetch('PORT')
  @pid = Process.pid
  @num_processes = ENV.fetch('NUM_PROCESSES') { 1 }.to_i
  @wait_readable = []
  @wait_writable = []

  class << self
    attr_accessor :app,
                  :host,
                  :port,
                  :pid,
                  :num_processes

    attr_reader :wait_readable,
                :wait_writable

    def call
      @wait_readable << TCPServer.new(@host, @port)

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
