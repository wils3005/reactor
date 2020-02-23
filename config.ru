# frozen_string_literal: true

require 'flump'
require 'grape'

if ENV['PUMA'] && !ENV['PUMA'].empty?
  require 'rack/handler/puma'

  class App < Grape::API
    format :json

    resource :users do
      get do
        Flump::User.order(Arel.sql('random()')).limit(1)
      end
    end
  end

  Rack::Handler::Puma.run App.new
else
  require 'flump/pg_connection'
  require 'rack/handler/flump'

  class App < Grape::API
    SQL = <<~SQL
      SELECT *
      FROM users
      ORDER BY random()
      LIMIT 1
      ;
    SQL

    format :json

    resource :users do
      get do
        Flump.pg_pool.select { _1.transaction_status.zero? }.sample.query_async(SQL)
      end
    end
  end

  Rack::Handler::Flump.run App.new
end

# puma/lambda = 2574.68 trans/sec
# puma/grape = 690.82 trans/sec
# puma/grape/active_record = 179.60 trans/sec, 65,656 kb

# flump/lambda = 4986.75 trans/sec
# flump/grape = 917.19 trans/sec, 35,388 kb
# flump/grape/pg = 41.71 trans/sec, 49,976 kb
