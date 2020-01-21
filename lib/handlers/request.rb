# frozen_string_literal: true

puts(__FILE__)

require_relative '../reactor'
require_relative 'response'

MAXLEN = 16_384

Reactor.handler :request do
  req = read_nonblock(MAXLEN)

  header, body = req.split("\r\n\r\n")
  header = header.split("\r\n")
  method, path, version = header.shift.split
  headers = header.map { _1.split(': ') }.to_h

  @request = {
    method: method,
    path: path,
    version: version,
    headers: headers,
    body: body.to_s
  }

  Reactor.unregister(io: self, mode: :read)

  Reactor.register(
    io: self,
    mode: :write,
    handler: :response
  )
rescue EOFError => e
  Reactor.unregister(io: self, mode: :read)
  $stdout.puts e.inspect
end
