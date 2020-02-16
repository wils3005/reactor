# frozen_string_literal: true

require 'fiber'
require 'socket'
require_relative 'flump/core_ext/tcp_server'

module Flump
  CONTENT_TYPE_HTML = 'text/html; charset=utf-8'
  CONTENT_TYPE_JSON = 'application/json; charset=utf-8'

  WAIT_READABLE = []
  WAIT_WRITABLE = []

  @host = ENV.fetch('HOST') { '127.0.0.1' }
  @port = ENV.fetch('PORT') { '49916' }
  @num_processes = ENV.fetch('NUM_PROCESSES') { 1 }.to_i
  @pid = Process.pid

  def self.call
    ::TCPServer.new(@host, @port).wait_readable!
    warn("Flump process #{@pid} listening at http://#{@host}:#{@port}!")

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    (@num_processes - 1).times { Process.fork if Process.pid == @pid }
    loop { select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume) }
  end
end
