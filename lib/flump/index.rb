# frozen_string_literal: true

module Flump
  module Index
    def self.call
      method = 'GET'
      path = '/'
      host = 'www.google.com'
      port = 80

      response =
        ::TCPSocket.
        new(host, port).
        write_read(method: method, path: path, host: host)

      body = format(
        INDEX_HTML,
        title: 'Flump!',
        google: response[/\A.+\r\n\r\n/m].gsub("\r\n", '<br />'),
        host: HOST,
        port: PORT
      )

      { body: body }
    rescue => @error
      warn(inspect)
      raise @error
    end
  end
end
