# frozen_string_literal: true

require 'stringio'

module Flump
  module HTTP
    # https://www.rubydoc.info/github/rack/rack/file/SPEC
    module RequestDeserializer
      def self.call(socket)
        request_line_and_headers, body = socket.read_async.split("\r\n\r\n")
        request_line_and_headers = request_line_and_headers.split("\r\n")

        request_method, path_with_query, http_version =
          request_line_and_headers.shift.split

        request_path, query_string = path_with_query.to_s.split('?')

        env = {
          'REQUEST_METHOD' => request_method,
          'SCRIPT_NAME' => '',
          'PATH_INFO' => request_path,
          'QUERY_STRING' => query_string.to_s,
          'SERVER_NAME' => Flump.host,
          'SERVER_PORT' => Flump.port,
          'HTTP_VERSION' => http_version,
          'REQUEST_PATH' => request_path,
          'rack.input' => StringIO.new(body.to_s),
          'rack.version' => [1, 3],
          'rack.errors' => STDERR,
          'rack.multithread' => false,
          'rack.multiprocess' => false,
          'rack.run_once' => false,
          'rack.url_scheme' => 'http'
        }

        headers = request_line_and_headers.each do |str|
          key, value = str.split(': ')

          case key.upcase!
          when 'CONTENT-TYPE', 'CONTENT-LENGTH'
            env[key] = value
          else
            env["HTTP_#{key}"] = value
          end
        end

        env
      end
    end
  end
end
