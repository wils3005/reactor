# frozen_string_literal: true

module Flump
  module IO
    NoCallbackError = Class.new(IOError)

    def flump
      raise(NoCallbackError, inspect)
    end
  end
end
