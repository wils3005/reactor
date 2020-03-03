# frozen_string_literal: true

ENV.merge!(`cat .env`.split("\n").map { |it| it.split('=') }.to_h)

require 'json'
require_relative 'lib/flump'
