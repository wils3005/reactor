# frozen_string_literal: true

module Flump
  module HTTP
    module RequestSerializer
      def self.call(method:, host:, path:, query: {}, headers: {}, body: '')
        serialized_headers =
          { 'Host' => host }.
          merge(headers).
          map { |k, v| "#{k}: #{v}" }.
          join("\r\n")

        serialized_query =
          query.any? ?
          query.map { |k, v| "#{k}=#{v}" }.join('&').prepend('?') :
          ''

        "#{method.to_s.upcase} #{path}#{serialized_query} HTTP/1.1\r\n" \
        "#{serialized_headers}\r\n" \
        "\r\n" \
        "#{body}"
      end
    end
  end
end
