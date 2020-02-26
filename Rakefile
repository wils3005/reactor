# frozen_string_literal: true

require 'yard'

task :default do
  system 'rake -T'
end

namespace :gem do
  desc "Build"
  task :build do
    system 'gem build flump.gemspec'
  end

  desc "Install"
  task :install do
    Rake::Task['gem:build'].invoke
    system 'gem install flump-0.1.0.gem'
  end
end

desc 'Deploy'
task :deploy do
  system 'git fetch'
  system 'git reset --hard origin/master'
  Rake::Task['gem:install'].invoke
  system 'chown -R flump:flump /home/flump'
  system 'systemctl restart flump.service'
end

namespace :db do
  desc "Create user"
  task :createuser do
    system 'createuser flump'
  end

  desc "Create database"
  task :createdb do
    system 'createdb flump --owner=flump'
  end

  desc "Create UUID extension"
  task :create_uuid_extension do
    require 'pg'
    require_relative 'lib/flump'

    sql = <<~SQL
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    SQL

    PG::Connection.query_async(sql)
  end

  desc "Create users table"
  task :create_users_table do
    require_relative 'lib/flump'

    sql = <<~SQL
      CREATE TABLE IF NOT EXISTS users (
      id uuid DEFAULT uuid_generate_v4() primary key,
      email text,
      encrypted_password text,
      first_name text,
      last_name text,
      date_of_birth text,
      full_address text,
      created_at timestamp NOT NULL DEFAULT NOW(),
      updated_at timestamp NOT NULL DEFAULT NOW(),
      deleted_at timestamp
      );
    SQL

    PG::Connection.query_async(sql)
  end

  desc "Insert 1000 records into users table"
  task :insert_users do
    require 'faker'
    require_relative 'lib/flump'

    random_user_sql = lambda do |*|
      arr = [
        Faker::Internet.free_email,
        Digest::SHA1.base64digest(Faker::Internet.password),
        Faker::Name.first_name,
        Faker::Name.last_name.tr("'", ''),
        Faker::Date.birthday.to_s,
        Faker::Address.full_address.tr("'", '')
      ]

      str = arr.map { |a| "'#{a}'" }.join(', ')
      "(#{str})"
    end

    users_sql = Array.new(1_000, &random_user_sql).join(', ')

    sql = <<~SQL
      INSERT INTO users(email, encrypted_password, first_name, last_name, date_of_birth, full_address)
      VALUES #{users_sql}
    SQL

    Thread.new do
      loop do
        select(Flump::WAIT_READABLE, Flump::WAIT_WRITABLE).flatten.each(&:resume)
      end
    end

    Fiber.new { PG::Connection.query_async(sql) }.resume
  end
end

YARD::Rake::YardocTask.new
