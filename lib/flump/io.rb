# frozen_string_literal: true

module Flump
  module IO
    def call
      raise(NoCallbackError)
    end
  end
end
