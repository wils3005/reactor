# frozen_string_literal: true

class TCPSocket
  MAXLEN = 16_384

  private

  def fiber
    @fiber ||= Fiber.new do
      Reactor::READ << self
      Fiber.yield
      # request = read_nonblock(MAXLEN)
      # Reactor::READ.delete(self)
      # write_nonblock(Response.new(request))
      write_nonblock(Response.new(read_nonblock(MAXLEN)))
      close
    rescue IOError => e
      puts(e.inspect)
    ensure
      Reactor::READ.delete(self)
    end
  end
end
