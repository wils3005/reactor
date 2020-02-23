# frozen_string_literal: true

require 'rack/handler/flump'
require 'flump'

Rack::Handler::Flump.run Flump::API.new

# puma/lambda = 2574.68 trans/sec
# puma/grape = 690.82 trans/sec
# puma/grape/active_record = 179.60 trans/sec, 65,656 kb

# flump/lambda = 4986.75 trans/sec
# flump/grape = 917.19 trans/sec, 35,388 kb
# flump/grape/pg = 41.71 trans/sec, 49,976 kb
