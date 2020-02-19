# frozen_string_literal: true

require 'fiber'
require 'socket'
require_relative 'flump/dsl'
require_relative 'flump/core_ext/tcp_server'

module Flump
  CONTENT_TYPE_HTML = 'text/html; charset=utf-8'
  CONTENT_TYPE_JSON = 'application/json; charset=utf-8'

  WAIT_READABLE = []
  WAIT_WRITABLE = []

  HOST = ENV.fetch('HOST') { '127.0.0.1' }
  PORT = ENV.fetch('PORT') { '49916' }
  NUM_PROCESSES = ENV.fetch('NUM_PROCESSES') { 1 }.to_i
  MASTER_PID = Process.pid

  def self.call
    ::TCPServer.new(HOST, PORT).wait_readable!
    warn("Flump process #{MASTER_PID} listening at http://#{HOST}:#{PORT}!")

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    (NUM_PROCESSES - 1).times { Process.fork if Process.pid == MASTER_PID }
    loop { select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume) }
  end
end
