# frozen_string_literal: true

puts __FILE__

module Reactor
  MAXLEN = 16_384
  READ = []
  WRITE = []
  ERROR = []

  ReactorRegistrationError = Class.new(IOError)
  ReactorCallbackError = Class.new(IOError)

  module ClassMethods
    def reactor
      loop { select(READ, WRITE, ERROR).flatten.each(&:reactor_callback) }
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def register(mode, callback_name)
    @mode = mode << self
    @callback_name = "_reactor_#{callback_name}"
  rescue NameError
    raise(ReactorRegistrationError, inspect)
  end

  def reactor_callback
    __send__(@callback_name)
  rescue NoMethodError
    raise(ReactorCallbackError, inspect)
    unregister
  end

  private

  def unregister
    @mode.delete(self)
  end
end

IO.include(Reactor)
