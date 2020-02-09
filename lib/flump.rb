# frozen_string_literal: true

require 'digest/sha1'
require 'fiber'
require 'socket'

# require 'pg'

pattern = File.join(__dir__, '**', '*.rb')
Dir.glob(pattern).sort.each(&method(:require))

module Flump
  def self.call
    READ << ::TCPServer.new(HOST, PORT)
    warn "Listening at http://#{HOST}:#{PORT}!"

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    (Flump::NUM_PROCESSES - 1).times do
      Process.fork if Process.pid == Flump::MASTER_PID
    end

    loop { select(READ, WRITE, ERROR).flatten.each(&:resume) }
  end
end
