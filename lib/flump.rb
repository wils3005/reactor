# frozen_string_literal: true

require 'fiber'
require 'socket'

require_relative 'flump/constants'
require_relative 'flump/dsl'
require_relative 'flump/regexp'
require_relative 'flump/router'
require_relative 'flump/reactor'
require_relative 'flump/time'

extend Flump::DSL
require_relative '../app/index'
require_relative '../app/google'
require_relative '../app/healthz'

module Flump
  ::Regexp.include Regexp
  ::Time.extend Time

  def self.call
    ::TCPServer.listen_async
    (NUM_PROCESSES - 1).times { Process.fork if Process.pid == MASTER_PID }
    Reactor.call
  end
end
