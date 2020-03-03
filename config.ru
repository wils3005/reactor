# frozen_string_literal: true

require 'rack/handler/flump'

Rack::Handler::Flump.run ->(env) { [200, {}, []] },
                         host: ENV.fetch('HOST'),
                         port: ENV.fetch('PORT')
