# frozen_string_literal: true

module Flump
  module String
    def base64digest
      Digest::SHA1.base64digest(self)
    end

    def http_content
      return "\r\n" if empty?

      "Content-Type: #{CONTENT_TYPE_HTML}\r\n" \
      "Content-Length: #{size}\r\n" \
      "\r\n" \
      "#{self}"
    end
  end

  ::String.include String
end
