# frozen_string_literal: true

puts __FILE__

class Server
  def initialize(reactor)
    TCPServer.
      new(ENV.fetch('HOST'), ENV.fetch('PORT')).
      register(reactor, :read, :accept)

    puts "Listening on port #{ENV.fetch('PORT')}!"
    $stdout.flush
  end
end
