# frozen_string_literal: true

module Flump
  module DSL
    def get(path, &block)
      Router.get(path, &block)
    end
  end
end
