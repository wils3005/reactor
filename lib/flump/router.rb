# frozen_string_literal: true

module Flump
  module Router
    @routes = Hash.new([]).merge!(
      'CONNECT' => [],
      'DELETE' => [],
      'GET' => [],
      'HEAD' => [],
      'OPTIONS' => [],
      'PATCH' => [],
      'POST' => [],
      'PUT' => [],
      'TRACE' => []
    )

    @routes.keys.each do |key|
      define_singleton_method(key.downcase) do |path, &block|
        path.define_singleton_method(:call, &block)
        @routes['GET'] << path
      end
    end

    def self.call(method, path)
      regexp = @routes[method].find do |regexp|
        path =~ regexp
      rescue TypeError => @error
        stderr
      end

      regexp&.call
    end
  end
end
