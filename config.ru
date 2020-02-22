# frozen_string_literal: true

require 'active_record/rack'
require 'flump'

use ActiveRecord::Rack::ConnectionManagement

require 'grape'
class App < Grape::API
  format :json

  resource :users do
    get do
      Flump::User.order(Arel.sql('random()')).limit(1)
    end
  end
end

if ENV['PUMA'] && !ENV['PUMA'].empty?
  require 'rack/handler/puma'

  Rack::Handler::Puma.run App.new
else
  require 'rack/handler/flump'

  Rack::Handler::Flump.run App.new
end

# flump/lambda = 4986.75 trans/sec
# flump/grape = 917.19 trans/sec, 35,388 kb

# puma/lambda = 2574.68 trans/sec
# puma/grape = 690.82 trans/sec
# puma/grape/active_record =
