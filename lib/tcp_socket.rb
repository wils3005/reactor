# frozen_string_literal: true

class TCPSocket
  MAXLEN = 16_384

  def call
    write_nonblock(Response.new(read_nonblock(MAXLEN)))
    close
  rescue IOError => e
    puts(e.inspect)
  ensure
    Reactor::READ.delete(self)
  end

  private

  # def fiber
  #   @fiber ||= Fiber.new do
  #     Reactor::READ << self
  #     Fiber.yield
  #     write_nonblock(Response.new(read_nonblock(MAXLEN)))
  #     close
  #   rescue IOError => e
  #     puts(e.inspect)
  #   ensure
  #     Reactor::READ.delete(self)
  #   end
  # end
end
