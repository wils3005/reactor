# frozen_string_literal: true

module Flump
  module Fiber
    attr_accessor :io

    ::Fiber.include(self)
  end
end
