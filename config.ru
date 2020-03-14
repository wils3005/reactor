# frozen_string_literal: true

require 'rack/handler/flump'

app = Flump::Application.new

app.body = format(
  File.read('index.html'),
  title: 'flump!',
  host: ENV.fetch('HOST'),
  port: ENV.fetch('PORT')
)

Rack::Handler::Flump.run(
  app,
  host: ENV.fetch('HOST'),
  port: ENV.fetch('PORT')
)
