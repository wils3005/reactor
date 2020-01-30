# frozen_string_literal: true

module Flump
  module TCPServer
    def call
      Reactor::READ << accept_nonblock
    rescue ::IO::EAGAINWaitReadable
    rescue => @error
      stderr
    end
  end
end
