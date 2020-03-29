# frozen_string_literal: true

require_relative 'lib/flump'

task :default do
  system 'rake -T'
end

desc 'Build'
task :build do
  system 'gem build flump.gemspec'
end

desc 'Install'
task :install do
  Rake::Task['build'].invoke
  system "gem install flump-#{Flump::VERSION}.gem"
end

desc 'Deploy'
task :deploy do
  system 'git fetch'
  system 'git reset --hard origin/master'
  Rake::Task['install'].invoke
  system 'chown -R flump:flump /home/flump'
  system 'systemctl restart flump.service'
end
