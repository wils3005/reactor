# frozen_string_literal: true

module Flump
  module TCPServer
    def flump
      Reactor::READ << accept_nonblock
    rescue ::IO::EAGAINWaitReadable
    rescue => e
      STDERR.write_nonblock("#{Process.pid} #{inspect} #{e.inspect}\n")
    end
  end
end
