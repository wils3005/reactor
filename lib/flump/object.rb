# frozen_string_literal: true

module Flump
  module Object
    def stderr
      @pid = Process.pid
      STDERR.write_nonblock("#{pid} #{to_s} #{instance_variables_with_values}\n")
    end

    def instance_variables_with_values
      instance_variables.each_with_object({}) do
        _2[_1] = instance_variable_get(_1)
      end
    end
  end
end
