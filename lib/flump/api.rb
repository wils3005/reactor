# frozen_string_literal: true

require 'grape'

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
        Flump.query(SQL).to_a
      end
    end
  end
end
