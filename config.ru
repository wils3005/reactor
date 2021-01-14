# frozen_string_literal: true

require 'pry'
require_relative './lib/rack/handler/flump'

Rack::Handler::Flump.run ->(_env) { [200, { 'Content-Type' => 'text/plain' }, []] }
