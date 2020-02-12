# frozen_string_literal: true

require 'objspace'

require 'faker'
require 'pg'

require_relative 'lib/flump'

Thread.new do
  Flump.call
rescue Errno::EADDRINUSE
end

def random_user_sql
  arr = [
    Faker::Internet.free_email,
    Digest::SHA1.base64digest(Faker::Internet.password),
    Faker::Name.first_name,
    Faker::Name.last_name.tr("'", ''),
    Faker::Date.birthday.to_s,
    Faker::Address.full_address.tr("'", '')
  ]

  str = arr.map { "'#{_1}'" }.join(', ')
  "(#{str})"
end

def random_users_sql(num)
  Array.new(num) { random_user_sql }.join(', ')
end

def create_users(num)
  sql = <<~SQL
    INSERT INTO users(email, encrypted_password, first_name, last_name, date_of_birth, full_address)
    VALUES #{random_users_sql(num)}
  SQL

  PG::Connection.query_async(sql)
end
