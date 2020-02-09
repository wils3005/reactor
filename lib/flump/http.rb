# frozen_string_literal: true

module Flump
  module HTTP
    def self.request(method:, path:, host:, content: nil)
      "#{method} #{path} HTTP/1.1\r\n" \
      "Host: #{host}\r\n" \
      "User-Agent: flump/0.1.0\r\n" \
      "Accept: */*\r\n" \
      "Connection: keep-alive\r\n" \
      "#{content || "\r\n"}"
    end
  end
end
