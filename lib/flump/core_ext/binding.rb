# frozen_string_literal: true

module Flump
  module Binding
    def stderr
      warn(info.to_s)
    end

    def info
      {
        receiver: receiver.to_s,
        local_variables: local_variables.each_with_object({}) { |a,b| b[a] = local_variable_get(a).to_s },
        instance_variables: instance_variables.each_with_object({}) { |a,b| b[a] = instance_variable_get(a).to_s }
      }
    end

    ::Binding.include(self)
  end
end
