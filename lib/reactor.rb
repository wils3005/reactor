# frozen_string_literal: true

puts __FILE__

module Reactor
  MAXLEN = 16_384

  READ = [].freeze
  WRITE = [].freeze
  ERROR = [].freeze

  ReactorRegistrationError = Class.new(IOError)
  ReactorCallbackError = Class.new(IOError)

  module ClassMethods
    def reactor
      loop { select(READ, WRITE, ERROR).flatten.each(&:reactor_callback) }
    end
  end

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  def register(mode, callback_name)
    @mode = mode << self
    @callback_name = "_reactor_#{callback_name}"
  rescue => e
    puts ReactorRegistrationError.new(e.inspect)
  end

  def reactor_callback
    __send__(@callback_name)
  rescue => e
    puts ReactorCallbackError.new(e.inspect)
    unregister
  end

  private

  def unregister
    @mode.delete(self)
  end
end

IO.include(Reactor)
