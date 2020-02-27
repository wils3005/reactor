# frozen_string_literal: true

module Flump
  class API < Grape::API
    format :json

    resource :users do
      get do
        Flump::User.order('random()').limit(1)
      end
    end
  end
end
