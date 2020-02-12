# frozen_string_literal: true

module Flump
  module Router
    @routes = ::Hash.new([]).merge!(
      'CONNECT' => [],
      'DELETE' => [],
      'GET' => [],
      'HEAD' => [],
      'OPTIONS' => [],
      'PATCH' => [],
      'POST' => [],
      'PUT' => [],
      'TRACE' => []
    ).freeze

    @not_found = ->{ [404, { 'Connection' => 'close' }, ''] }

    def self.call(method, path)
      @routes[method].find(@not_found) { path =~ _1 }&.call
    end

    def self.push(method, path)
      @routes[method].push(path)
    end
  end
end
