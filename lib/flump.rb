# frozen_string_literal: true

require 'fiber'
require 'socket'

require_relative 'flump/configuration'
require_relative 'flump/constants'

if Flump::DSL_ENABLED
  require_relative 'flump/dsl'
  extend Flump::DSL
end

require_relative 'flump/io'
::IO.include Flump::IO

require_relative 'flump/object'
::Object.include Flump::Object

require_relative 'flump/regexp'
::Regexp.include Flump::Regexp

require_relative 'flump/tcp_server'
::TCPServer.include Flump::TCPServer

require_relative 'flump/tcp_socket'
::TCPSocket.include Flump::TCPSocket

require_relative 'flump/reactor'
require_relative 'flump/router'

require_relative '../app/index/route'
require_relative '../app/healthz/route'

module Flump
  def self.call
    STDERR.write_nonblock("#{ENV.sort.to_h}\n")
    Reactor::READ << ::TCPServer.new(ENV.fetch('HOST'), ENV.fetch('PORT'))
    STDERR.write_nonblock("Listening at http://#{ENV.fetch('HOST')}:#{ENV.fetch('PORT')}!\n")
    (NUM_PROCESSES - 1).times { Process.fork if Process.pid == MASTER_PID }
    STDERR.write_nonblock("Process #{Process.pid} up!\n")
    Reactor.call
    STDERR.write_nonblock("Process #{Process.pid} shutting down...\n")
  end
end
