# frozen_string_literal: true

require 'rack/handler'
require_relative '../../flump'

module Rack
  module Handler
    module Flump
      def self.run(app, **options)
        ::Flump.call(app, **options)
      end
    end

    register :flump, Flump
  end
end
