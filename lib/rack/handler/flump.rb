# frozen_string_literal: true

require 'rack/handler'
require 'flump'

module Rack
  module Handler
    module Flump
      def self.run(app)
        ::Flump.call(app)
      end
    end

    register :flump, Flump
  end
end
