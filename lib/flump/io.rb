# frozen_string_literal: true

require 'fiber'
require 'socket'

class IO
  @@maxlen = 16_384
  @@wait_readable = []
  @@wait_writable = []

  def self.wait_readable
    @@wait_readable
  end

  def self.wait_writable
    @@wait_writable
  end

  def self.resume
    select(@@wait_readable, @@wait_writable).flatten.each(&:resume)
  end

  def resume
    @fiber.resume
  end

  def read_async(int = @@maxlen)
    buffer = read_nonblock(int)
    return buffer if buffer.length < @@maxlen

    buffer += read_async(int)
  rescue ::IO::WaitReadable
    @@wait_readable.push(self)
    @fiber = Fiber.current
    Fiber.yield
    @@wait_readable.delete(self)
    retry
  end

  def read_write_async
    write_async(yield read_async)
    close
  rescue EOFError, Errno::ECONNRESET => e
    close
    raise e
  end

  def write_async(buffer)
    write_nonblock(buffer)
  rescue ::IO::WaitWritable
    @@wait_writable.push(self)
    @fiber = Fiber.current
    Fiber.yield
    @@wait_writable.delete(self)
    retry
  end

  def write_read_async(buffer)
    read_async(yield write_async(buffer))
    close
  rescue EOFError, Errno::ECONNRESET => e
    close
    raise e
  end
end
