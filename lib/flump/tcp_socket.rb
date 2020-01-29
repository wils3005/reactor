# frozen_string_literal: true

module Flump
  module TCPSocket
    MAXLEN = 16_384

    def flump
      @request ||= read_nonblock(MAXLEN)
      Reactor::READ.delete(self)
      deserialize_request!
      serialize_response!
      write_nonblock(@response)
      Reactor::WRITE.delete(self)
      close
    rescue ::IO::EAGAINWaitReadable => e
      STDERR.write_nonblock("#{Process.pid} #{inspect} #{e.inspect}\n")
    rescue ::IO::EAGAINWaitWritable => e
      STDERR.write_nonblock("#{Process.pid} #{inspect} #{e.inspect}\n")
      Reactor::WRITE << self
    rescue IOError => e
      STDERR.write_nonblock("#{Process.pid} #{inspect} #{e.inspect}\n")
      Reactor::READ.delete(self)
      Reactor::WRITE.delete(self)
    end
  end
end
