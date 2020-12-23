# typed: false
# frozen_string_literal: true

require 'fiber'
require 'socket'

class TCPServer
  def resume
    Fiber.new { accept_nonblock.read_write_async }.resume
  rescue ::IO::WaitReadable => e
    Flump.logger.warn(e)
  end
end
