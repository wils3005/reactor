# frozen_string_literal: true

get /\A\/google\z/ do
  host = 'www.google.ca'
  port = 80
  response = ::TCPSocket.new(host, port).write_request_and_read_response

  "#{'#' * 80}\n#{response}\n#{'#' * 80}\n"
end
