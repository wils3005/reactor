# frozen_string_literal: true

class TCPServer
  private

  def fiber
    @fiber ||= Fiber.new do
      Reactor::READ << self

      loop do
        Fiber.yield
        accept_nonblock.resume
      end
    end
  end
end

# address_family, port, hostname, numeric_address = addr
