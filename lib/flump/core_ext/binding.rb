# frozen_string_literal: true

module Flump
  module Binding
    def stderr
      warn(info.to_s)
    end

    def info
      {
        receiver: receiver.to_s,
        source_location: source_location.to_a.join(':'),
        local_variables: local_variables.each_with_object({}) { _2[_1] = local_variable_get(_1).to_s },
        instance_variables: instance_variables.each_with_object({}) { _2[_1] = instance_variable_get(_1).to_s }
      }
    end

    ::Binding.include(self)
  end
end
