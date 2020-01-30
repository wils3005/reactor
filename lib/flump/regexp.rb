# frozen_string_literal: true

module Flump
  module Regexp
    def call
      raise(NoCallbackError)
    end
  end
end
