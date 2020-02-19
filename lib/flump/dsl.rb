# frozen_string_literal: true

require_relative 'http/exchange'

MAIN = self

module Flump
  module DSL
    HTTP::Exchange::EXCHANGES.keys.each do |http_method|
      ::MAIN.define_singleton_method(http_method.downcase) do |path, &block|
        HTTP::Exchange.new(http_method, path, &block)
      end
    end
  end
end
