# frozen_string_literal: true

module Flump
  module TCPServer
    def resume
      Flump.async { HTTPConnection.new(accept_nonblock).read_write }
    end
  end
end
