# frozen_string_literal: true

get /\A\/google\z/ do
  ::TCPSocket.
    new('www.google.ca', 80).
    client_request_async("GET / HTTP/1.1\r\n\r\n")
end
