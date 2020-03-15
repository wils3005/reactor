# frozen_string_literal: true

require 'rack/handler/flump'

Rack::Handler::Flump.run(
  Flump::Application.new,
  host: ENV.fetch('HOST'),
  port: ENV.fetch('PORT')
)
