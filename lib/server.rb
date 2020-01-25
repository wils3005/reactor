# frozen_string_literal: true

puts __FILE__

class Server
  def initialize
    TCPServer.
      new(ENV.fetch('HOST'), ENV.fetch('PORT')).
      register(IO::READ, :accept)

    puts "Listening at http://#{ENV.fetch('HOST')}:#{ENV.fetch('PORT')}!"
  end
end
