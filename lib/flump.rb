# frozen_string_literal: true

require 'digest/sha1'
require 'fiber'
require 'socket'

require 'pg'

Dir.glob(File.join(__dir__, '**', '*.rb')).sort.each(&method(:require))
Flump::APP_FILES.each(&method(:require))

module Flump
  def self.call
    ::TCPServer.new(HOST, PORT).wait_readable!
    warn "Listening at http://#{HOST}:#{PORT}!"

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    (Flump::NUM_PROCESSES - 1).times do
      Process.fork if Process.pid == Flump::MASTER_PID
    end

    loop { select(WAIT_READABLE, WAIT_WRITABLE).flatten.each(&:resume) }
  end
end
