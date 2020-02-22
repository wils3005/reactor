# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(
  host: '127.0.0.1',
  adapter: 'postgresql',
  encoding: 'utf-8',
  database: 'flump',
  user: 'flump',
  password: 'flump'
)

module Flump
  class User < ActiveRecord::Base
  end
end
