# frozen_string_literal: true

module Flump
  class HTTPRequest
    def self.parse(str)
      request_line_and_headers, body = str.split("\r\n\r\n")
      request_line_and_headers = request_line_and_headers.split("\r\n")
      body = body.to_s
      method, path, version = request_line_and_headers.shift.split
      headers = request_line_and_headers.map { _1.split(': ') }.to_h
      method = method.to_s
      path, query = path.to_s.split('?')
      version = version.to_s.split('/').last.to_f
      query = query.to_s.split('&').map { _1.split('=') }.to_h
      return if method.empty? || path.empty? || version < 1.0 || !headers.key?('Host')

      new(
        host: headers['Host'],
        method: method,
        path: path,
        query: query,
        version: version,
        headers: headers,
        body: body
      )
    end

    attr_reader :host,
                :method,
                :path,
                :query,
                :version,
                :headers,
                :body,
                :to_s

    def initialize(host:, method:, path:, query: {}, version: 1.1, headers: {}, body: '')
      @host = host
      @method = method
      @path = path
      @query = query
      @version = version
      @headers = headers
      @body = body
      @to_s = _to_s
    end

    private

    def _to_s
      headers =
        _default_headers.
        merge(@headers).
        map { "#{_1}: #{_2}" }.
        join("\r\n")

      "#{@method} #{@path} HTTP/#{@version}\r\n" \
      "#{headers}\r\n" \
      "\r\n" \
      "#{@body}"
    end

    def _default_headers
      {
        'Host' => @host,
        'User-Agent' => 'flump/0.1.0',
        'Accept' => '*/*',
        'Connection' => 'keep-alive'
      }
    end
  end
end
