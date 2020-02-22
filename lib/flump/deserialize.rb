# frozen_string_literal: true

require 'puma/null_io'

module Flump
  module Deserialize
    def deserialize(raw_request)
      env = {}

      request_line_and_headers, body = raw_request.split("\r\n\r\n")
      request_line_and_headers = request_line_and_headers.split("\r\n")
      body = body.to_s

      request_method, path_with_query, http_version =
        request_line_and_headers.shift.split

      headers = request_line_and_headers.each do |str|
        k,v = str.split(': ')
        env["HTTP_#{k.upcase}"] = v
      end

      request_path, query_string = path_with_query.to_s.split('?')

      env['SCRIPT_NAME'] = ''
      env['SERVER_NAME'] = Flump.host
      env['SERVER_PORT'] = Flump.port
      env['REQUEST_METHOD'] = request_method
      env['REQUEST_PATH'] = request_path
      env['PATH_INFO'] = request_path
      env['QUERY_STRING'] = query_string.to_s
      env['HTTP_VERSION'] = http_version
      env['rack.input'] = Puma::NullIO.new
      env
    end
  end
end
