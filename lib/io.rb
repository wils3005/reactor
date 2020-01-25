# frozen_string_literal: true

puts __FILE__

class IO
  MAXLEN = 16_384
  READ = []
  WRITE = []
  ERROR = []

  ReactorRegistrationError = Class.new(IOError)
  ReactorCallbackError = Class.new(IOError)

  def self.reactor
    loop { select(READ, WRITE, ERROR).flatten.each(&:reactor_callback) }
  end

  def register(mode, callback_name)
    @mode = mode << self
    @callback_name = "reactor_#{callback_name}"
  rescue NameError
    raise(ReactorRegistrationError, inspect)
  end

  def reactor_callback
    __send__(@callback_name)
  rescue NoMethodError
    raise(ReactorCallbackError, inspect)
  end

  private

  def reactor_accept
    accept_nonblock.register(IO::READ, :request)
  rescue IOError => e
    puts(e.inspect)
    unregister
  end

  def reactor_request
    @request = read_nonblock(MAXLEN)
    close_read
    unregister
    register(IO::WRITE, :response)
  rescue IOError => e
    puts(e.inspect)
    unregister
  end

  def reactor_response
    write_nonblock(Response.new(@request))
    close_write
    unregister
  rescue IOError => e
    puts(e.inspect)
    unregister
  end

  def unregister
    @mode.delete(self)
  end
end
