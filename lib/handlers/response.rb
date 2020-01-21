# frozen_string_literal: true

puts(__FILE__)

require 'json'

require_relative '../reactor'

RESPONSE = "HTTP/1.1 200 OK\r\n" \
           "Content-Type: text/html; charset=utf-8\r\n" \
           "Date: %<date>s\r\n" \
           "Connection: close\r\n" \
           "Content-Length: %<content_length>s\r\n" \
           "\r\n" \
           "%<body>s"

Reactor.handler :response do
  response = format(
    RESPONSE,
    date: Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT'),
    content_length: @request.to_json.length,
    body: @request.to_json
  )

  write_nonblock(response)
  close
  Reactor.unregister(io: self, mode: :write)
end
