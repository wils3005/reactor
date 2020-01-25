# frozen_string_literal: true

puts __FILE__

class IO
  MAXLEN = 16_384

  # a socket needs to know of the read array, write array, callback for each?
  # register io for reactor callback
  def register(reactor, mode, callback_name)
    @reactor = reactor
    @mode = @reactor.__send__(mode)
    @callback_name = "reactor_#{callback_name}"

    @mode << self
  end

  # reactor callback
  def reactor_callback
    __send__(@callback_name)
  end

  private

  def reactor_accept
    accept_nonblock.register(@reactor, :read, :request)
  end

  def reactor_request
    @request = read_nonblock(MAXLEN)
    close_read
    unregister
    register(@reactor, :write, :response)
  rescue EOFError
    unregister
  end

  def reactor_response
    write_nonblock(Response.new(@request))
    close_write
    unregister
  end

  def unregister
    @mode.delete(self)
  end
end
