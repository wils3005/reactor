# frozen_string_literal: true

module Flump
  module TCPSocket
    MAXLEN = 16_384

    def flump
      write_nonblock(Middleware.new(read_nonblock(MAXLEN)))
      close
    rescue IOError => e
      puts(e.inspect)
    ensure
      Reactor::READ.delete(self)
    end
  end
end
