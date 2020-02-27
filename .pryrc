# frozen_string_literal: true

ENV.merge!(`cat .env`.split("\n").map { |it| it.split('=') }.to_h)

require 'json'
require_relative 'lib/flump'

Thread.new do
  Flump.host = ENV.fetch('HOST')
  Flump.port = ENV.fetch('PORT')
  Flump.process_pool_size = ENV.fetch('PROCESS_POOL_SIZE').to_i

  Flump.active_record_connection_params =
    JSON.parse(ENV.fetch('ACTIVE_RECORD_CONNECTION_PARAMS'))

    Flump.app = Flump::API.new
  # Flump.app = ->(env) { [204, {}, []] }
  Flump.call
end
