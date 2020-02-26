# frozen_string_literal: true

pattern = File.join(Dir.pwd, '**', '*.rb')

files =
  Dir.
  glob(pattern).
  map { |it| it[%r{(?<=#{Dir.pwd}/).+}] }.
  push('bin/flump')

Gem::Specification.new do |it|
  it.name        = 'flump'
  it.version     = '0.1.0'
  it.date        = '2020-02-25'
  it.author      = ['Jack Wilson']
  it.email       = ['wils3005@gmail.com']
  it.summary     = 'A lightweight framework for building network applications in ruby'
  it.description = <<~HEREDOC
    Incidunt alias reprehenderit. Nemo commodi et. Inventore soluta alias.
    Maiores aut nihil. Ullam consequatur qui. Dolores quas consectetur. Sint
    quia qui. Dolorem placeat ut. Deleniti molestiae distinctio. Enim
    perspiciatis laudantium.
  HEREDOC

  it.homepage              = 'https://github.com/wils3005/flump'
  it.license               = 'ISC'
  it.required_ruby_version = '>= 2.4.5'
  it.files                 = files
  it.executables           << 'flump'
end
