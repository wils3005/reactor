# frozen_string_literal: true

require_relative './lib/flump'

app = ->(_env) { [200, { 'Content-Type' => 'text/plain' }, []] }
options = {}

Rack::Handler::Flump.run(app, **options)
