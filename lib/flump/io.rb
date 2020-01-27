# frozen_string_literal: true

module Flump
  module IO
    NoHandlerError = Class.new(IOError)

    def flump
      raise(NoHandlerError, inspect)
    end
  end
end
