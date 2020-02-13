# frozen_string_literal: true

module Flump
  module DSL
    HTTP::METHODS.each do |http_method|
      define_method(http_method.downcase) do |route, &block|
        route.define_singleton_method(:call, &block)
        Router.push(http_method, route)
      end
    end
  end
end

extend(Flump::DSL)
