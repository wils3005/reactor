# frozen_string_literal: true

class TCPServer
  def call
    Reactor::READ << accept_nonblock
  end

  private

  # def fiber
  #   @fiber ||= Fiber.new do
  #     Reactor::READ << self

  #     loop do
  #       Fiber.yield
  #       accept_nonblock.resume
  #     end
  #   end
  # end
end

# address_family, port, hostname, numeric_address = addr
