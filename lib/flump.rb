# frozen_string_literal: true

require 'socket'

require_relative 'flump/dsl'
extend Flump::DSL

require_relative 'flump/io'
::IO.include Flump::IO

require_relative 'flump/tcp_server'
::TCPServer.include Flump::TCPServer

require_relative 'flump/request'
require_relative 'flump/response'
require_relative 'flump/tcp_socket'
::TCPSocket.include Flump::Request,
                    Flump::Response,
                    Flump::TCPSocket

require_relative 'flump/reactor'
require_relative 'flump/router'

require_relative '../app/index/route'
require_relative '../app/healthz/route'

module Flump
  PID = Process.pid

  def self.call
    Reactor::READ << ::TCPServer.new(ENV.fetch('HOST'), ENV.fetch('PORT'))
    STDERR.write_nonblock("Process #{PID} listening at http://#{ENV.fetch('HOST')}:#{ENV.fetch('PORT')}!\n")
    # Process.fork
    Reactor.run
    STDERR.write_nonblock("Process #{PID} shutting down...\n")
  end
end
