# frozen_string_literal: true

class IO
  # FiberlessIOError = Class.new(IOError)
  NoCallbackError = Class.new(IOError)

  def call
    raise(NoCallbackError, inspect)
  end

  private

  # def fiber
  #   raise(FiberlessIOError, inspect)
  # end
end
