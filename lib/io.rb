# frozen_string_literal: true

class IO
  FiberlessIOError = Class.new(IOError)

  def resume
    fiber.resume
  end

  private

  def fiber
    raise(FiberlessIOError, inspect)
  end
end
