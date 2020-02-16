# frozen_string_literal: true

module Flump
  module Binding
    def stderr
      warn(info.inspect)
    end

    def info
      {
        receiver => {
          **local_variables.sort.each_with_object({}) { |a,b| b[a] = local_variable_get(a) },
          **instance_variables.sort.each_with_object({}) { |a,b| b[a] = instance_variable_get(a) }
        }
      }
    end

    ::Binding.include(self)
  end
end
