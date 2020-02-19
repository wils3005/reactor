# frozen_string_literal: true

pattern = File.join(Dir.pwd, '**', '*.rb')
files = Dir.glob(pattern).map { _1[%r{(?<=#{Dir.pwd}/).+}] }

Gem::Specification.new do
  _1.name        = 'flump'
  _1.version     = '0.1.0'
  _1.date        = '2020-02-19'
  _1.author      = ['Jack Wilson']
  _1.email       = ['wils3005@gmail.com']
  _1.summary     = 'A lightweight framework for building network applications in ruby'
  _1.description = <<~HEREDOC
    Incidunt alias reprehenderit. Nemo commodi et. Inventore soluta alias.
    Maiores aut nihil. Ullam consequatur qui. Dolores quas consectetur. Sint
    quia qui. Dolorem placeat ut. Deleniti molestiae distinctio. Enim
    perspiciatis laudantium.
  HEREDOC

  _1.homepage              = 'https://github.com/wils3005/flump'
  _1.license               = 'ISC'
  _1.required_ruby_version = '>= 2.7.0'
  _1.files                 = files
end
