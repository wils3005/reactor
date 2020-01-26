# frozen_string_literal: true

module Flump
  module TCPSocket
    MAXLEN = 16_384

    def _reactor_callback
      write_nonblock(Response.new(read_nonblock(MAXLEN)))
      close
    rescue IOError => e
      puts(e.inspect)
    ensure
      Reactor::READ.delete(self)
    end
  end
end
