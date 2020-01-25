# frozen_string_literal: true

class TCPSocket
  MAXLEN = 16_384

  private

  def fiber
    @fiber ||= Fiber.new do
      Reactor::READ << self
      Fiber.yield
      request = read_nonblock(MAXLEN)
      Reactor::READ.delete(self)
      # Reactor::WRITE << self
      # Fiber.yield
      write_nonblock(Response.new(request))
      close
      # Reactor::WRITE.delete(self)
    end
  end
end
