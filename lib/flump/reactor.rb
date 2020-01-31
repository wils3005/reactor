# frozen_string_literal: true

require_relative 'reactor/stderr'
require_relative 'reactor/tcp_server'
require_relative 'reactor/tcp_socket'

module Flump
  module Reactor
    ::STDERR.extend STDERR
    ::TCPServer.include TCPServer
    ::TCPSocket.include TCPSocket

    READ = []
    WRITE = []
    ERROR = []

    def self.call
      trap('INT') { return }
      loop { ::IO.select(READ, WRITE, ERROR).flatten.each(&:resume) }
    end
  end
end
