# frozen_string_literal: true

require_relative 'response'

class IO
  MAXLEN = 16_384

  def self.reactor
    loop { select(reactor_read, reactor_write).flatten.each(&:reactor_handler) }
  end

  def self.reactor_read
    @reactor_read ||= []
  end

  def self.reactor_write
    @reactor_write ||= []
  end

  def reactor_handler
    __send__(@handler_name)
  end

  def register(mode, name)
    @mode = "reactor_#{mode}"
    @handler_name = "reactor_#{name}"

    IO.__send__(@mode) << self
  end

  private

  def unregister
    IO.__send__(@mode).delete(self)
  end

  def reactor_accept
    accept_nonblock.register(:read, :request)
  end

  def reactor_request
    @request = read_nonblock(MAXLEN)
    close_read
    unregister
    register(:write, :response)
  end

  def reactor_response
    write_nonblock(::Response.new(@request))
    close_write
    unregister
  end
end
