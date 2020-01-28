# frozen_string_literal: true

module Flump
  module TCPSocket
    include Request
    include Response

    MAXLEN = 16_384

    def flump
      @request ||= read_nonblock(MAXLEN)
      deserialize_request!
      Reactor::READ.delete(self)
      # short circuit bad requests here?
      @response ||= serialize_response!
      write_nonblock(@response)
      Reactor::WRITE.delete(self)
      close
    rescue ::IO::WaitReadable
      nil
    rescue ::IO::WaitWritable
      Reactor::WRITE << self
    rescue IOError => e
      STDOUT.puts(e.inspect)
      Reactor::READ.delete(self)
      Reactor::WRITE.delete(self)
    end
  end
end
