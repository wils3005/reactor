# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'flump'
  s.version     = '0.1.0'
  s.date        = '2020-01-26'
  s.author      = ['Jack Wilson']
  s.email       = ['wils3005@gmail.com']
  s.summary     = 'A microservice framework'
  s.description = s.summary
  s.homepage    = 'https://github.com/wils3005/flump'
  s.license     = 'ISC'
  s.executables << 'flump'

  s.files = [
    'lib/flump.rb',
    'lib/flump/io.rb',
    'lib/flump/middleware.rb',
    'lib/flump/reactor.rb',
    'lib/flump/tcp_server.rb',
    'lib/flump/tcp_socket.rb'
  ]
end
