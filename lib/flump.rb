# frozen_string_literal: true

require 'fiber'
require 'socket'

require 'active_record'
require 'grape'

require_relative 'flump/api'
require_relative 'flump/io'
require_relative 'flump/server'
require_relative 'flump/socket'
require_relative 'flump/user'

module Flump
  VERSION = '0.1.0'

  @pid = Process.pid
  @wait_readable = []
  @wait_writable = []

  class << self
    attr_accessor :app,
                  :host,
                  :port,
                  :process_pool_size,
                  :active_record_connection_params

    attr_reader :pid,
                :wait_readable,
                :wait_writable

    def call
      ActiveRecord::Base.establish_connection(@active_record_connection_params)
      @wait_readable << TCPServer.new(@host, @port)
      warn("Flump #{@pid} listening at http://#{@host}:#{@port}!")

      trap 'INT' do
        warn "\nShutting down...\n"
        exit
      end

      (@process_pool_size - 1).times { Process.fork if Process.pid == @pid }
      loop { select(@wait_readable, @wait_writable).flatten.each(&:resume) }
    end
  end
end
