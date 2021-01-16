# frozen_string_literal: true

require 'rack/handler'

module Rack
  module Handler
    module Flump
      def self.run(...)
        ::Flump.call(...)
      end
    end

    register :flump, Flump
  end
end
