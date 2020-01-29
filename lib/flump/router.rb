# frozen_string_literal: true

module Flump
  module Router
    @routes = Hash.new({}).merge!(
      'DELETE' => {},
      'GET' => {},
      'HEAD' => {},
      'PATCH' => {},
      'POST' => {},
      'PUT' => {},
    )

    def self.call(method, path)
      @routes[method].
        find { |route, handler| path =~ route }.
        to_a.
        last&.
        call
    end

    def self.get(path, &block)
      @routes['GET'][/\A#{path}\z/] = block
    end
  end
end
