# typed: true
# frozen_string_literal: true

require 'fiber'
require 'socket'

class IO
  MAXLEN = 16_384

  def resume
    @fiber.resume
  end

  def read_async(int = MAXLEN)
    chunk = read_nonblock(int)
    return chunk if chunk.length < MAXLEN

    chunk += read_async
  rescue ::IO::WaitReadable
    Flump.wait_readable << self
    @fiber = Fiber.current
    Fiber.yield
    Flump.wait_readable.delete(self)
    retry
  end

  def write_async(str)
    write_nonblock(str)
  rescue ::IO::WaitWritable
    Flump.wait_writable << self
    @fiber = Fiber.current
    Fiber.yield
    Flump.wait_writable.delete(self)
    retry
  end
end
