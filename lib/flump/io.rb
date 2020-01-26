# frozen_string_literal: true

module Flump
  module IO
    NoCallbackError = Class.new(IOError)

    def _reactor_callback
      raise(NoCallbackError, inspect)
    end
  end
end
