# frozen_string_literal: true

require 'fiber'
require 'socket'

class TCPServer
  attr_accessor :exchange

  def resume
    Fiber.new { accept_nonblock.read_write_async(&@exchange.method(:call)) }.resume
  rescue ::IO::WaitReadable => e
    Flump.logger.warn(e)
  end
end
