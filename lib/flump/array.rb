# frozen_string_literal: true

module Flump
  module Array
    def push_delete(obj)
      push(obj)
      yield
      delete(obj)
    end
  end

  ::Array.include Array
end
