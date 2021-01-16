# frozen_string_literal: true

require_relative 'lib/flump'

task :default do
  system 'rake -T'
end

desc 'Build gem'
task :build do
  system 'gem build flump.gemspec'
end

desc 'Install gem'
task :install do
  system "gem install flump-#{Flump::VERSION}.gem"
end

desc 'Start sample Rack application'
task :start do
  system 'rackup'
end
