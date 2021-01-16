# frozen_string_literal: true

require_relative './lib/flump'
require_relative './lib/rack/handler/flump'

Rack::Handler::Flump.run ->(_env) { [200, { 'Content-Type' => 'text/plain' }, []] }
