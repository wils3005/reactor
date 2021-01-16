# frozen_string_literal: true

require_relative 'lib/flump'

files =
  Dir
  .glob("#{Dir.pwd}/**/*.rb")
  .map { _1[%r{(?<=#{Dir.pwd}/).+}] }

Gem::Specification.new do
  _1.name                  = 'flump'
  _1.version               = Flump::VERSION
  _1.date                  = '2020-03-02'
  _1.author                = ['Jack Wilson']
  _1.email                 = ['wils3005@gmail.com']
  _1.files                 = files
  _1.summary               = 'A Rack-compatible TCP server with HTTP/1.1 support'
  _1.homepage              = 'https://github.com/wils3005/flump'
  _1.license               = 'MIT'
  _1.required_ruby_version = '~> 3.0'
  _1.add_dependency          'rack', '~> 2.2'

  _1.description = <<~HEREDOC
    Incidunt alias reprehenderit. Nemo commodi et. Inventore soluta alias.
    Maiores aut nihil. Ullam consequatur qui. Dolores quas consectetur. Sint
    quia qui. Dolorem placeat ut. Deleniti molestiae distinctio. Enim
    perspiciatis laudantium.
  HEREDOC
end
