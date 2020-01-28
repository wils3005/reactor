# frozen_string_literal: true

module Flump
  module Router
    class << self
      def call(method, path)
        routes[method].find { |route, handler| path =~ route } || :not_found
      end

      private

      def routes
        @routes ||= Hash.new({})
      end
    end
  end
end
