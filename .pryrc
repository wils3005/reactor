# frozen_string_literal: true

ENV.merge!(`cat .env`.split("\n").map { |it| it.split('=') }.to_h)

require_relative 'lib/flump'

Thread.new do
  Flump.app = Flump::API.new
  Flump.call
end
