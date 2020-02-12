# frozen_string_literal: true

require 'yard'

task default: ['build', 'install']

desc "Build gem"
task :build do
  system 'gem build flump.gemspec'
end

desc "Install gem"
task :install do
  system 'gem build flump.gemspec'
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
    require 'pg'
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
end

YARD::Rake::YardocTask.new
