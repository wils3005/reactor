# frozen_string_literal: true

require_relative 'flump/env'
require_relative 'flump/array'
require_relative 'flump/http'
require_relative 'flump/dsl'
require_relative 'flump/io'
require_relative 'flump/router'
require_relative 'flump/string'
require_relative 'flump/tcp_server'

require_relative 'flump/http/app'
require_relative 'flump/http/connection'
require_relative 'flump/http/hash'
require_relative 'flump/http/request'
require_relative 'flump/http/response'
require_relative 'flump/http/server'
require_relative 'flump/http/time'

require_relative 'flump/pg/connection'
require_relative 'flump/ws/connection'

Dir.glob(File.join(Dir.pwd, 'app', '**', '*.rb')).each(&method(:require))

module Flump
  DBNAME = ::ENV.fetch('DBNAME')
  HOST = ::ENV.fetch('HOST')
  NUM_PROCESSES = ::ENV.fetch('NUM_PROCESSES').to_i
  PORT = ::ENV.fetch('PORT')

  WAIT_READABLE = []
  WAIT_WRITABLE = []

  MASTER_PID = Process.pid
  MAX_PAYLOAD_SIZE = 16_384
  VERSION = '0.1.0'

  def self.call
    HTTP::Server.new.wait_readable!

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    (Flump::NUM_PROCESSES - 1).times do
      Process.fork if Process.pid == Flump::MASTER_PID
    end

    Thread.new do
      loop do
        select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume)
      end
    end

    sleep
  end
end
