# frozen_string_literal: true

require 'yard'

task default: ['build', 'install', 'yard']

desc "Run \"gem build flump.gemspec\""
task :build do
  system 'gem build flump.gemspec'
end

desc "Run \"gem install flump-0.1.0.gem\""
task :install do
  system 'gem install flump-0.1.0.gem'
end

YARD::Rake::YardocTask.new
