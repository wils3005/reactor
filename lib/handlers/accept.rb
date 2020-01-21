# frozen_string_literal: true

puts(__FILE__)

require_relative '../reactor'
require_relative 'request'

Reactor.handler :accept do
  Reactor.register(
    io: accept_nonblock,
    mode: :read,
    handler: :request
  )
end
