# frozen_string_literal: true

require_relative 'lib/flump'

Thread.new do
  Flump.app = Flump::API.new
  Flump.call
end
