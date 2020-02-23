# frozen_string_literal: true

require 'grape'
require_relative 'pg_connection'

module Flump
  class API < Grape::API
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
        Flump.pg_pool.select { _1.transaction_status.zero? }.sample.query_async(SQL).to_a
      end
    end
  end
end
