# frozen_string_literal: true

module Flump
  module Hash
    def http_headers
      map { "#{_1}: #{_2}" }.join("\r\n")
    end
  end

  ::Hash.include Hash
end
