# frozen_string_literal: true

require 'fiber'
require 'socket'

class TCPServer
  attr_accessor :block

  def resume
    Fiber.new { accept_nonblock.read_write_async(&block) }.resume
  rescue ::IO::WaitReadable
    nil
  end
end
