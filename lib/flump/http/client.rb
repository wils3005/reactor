# frozen_string_literal: true

require 'stringio'

module Flump
  module HTTP
    class Client
      HTTP_DATE = '%a, %d %b %Y %H:%M:%S GMT'
      HTTP_SERVER = 'Flump'

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
      REASON_PHRASES = {
        # Information responses
        100 => 'Continue',
        101 => 'Switching Protocols',
        102 => 'Processing',
        103 => 'Early Hints',
        # Successful responses
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        207 => 'Multi-Status',
        208 => 'Already Reported',
        226 => 'IM Used',
        # Redirection messages
        300 => 'Multiple Choice',
        301 => 'Moved Permanently',
        302 => 'Found',
        303 => 'See Other',
        304 => 'Not Modified',
        305 => 'Use Proxy',
        307 => 'Temporary Redirect',
        308 => 'Permanent Redirect',
        # Client error responses
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Payload Too Large',
        414 => 'URI Too Long',
        415 => 'Unsupported Media Type',
        416 => 'Range Not Satisfiable',
        417 => 'Expectation Failed',
        418 => 'I\'m A Teapot',
        421 => 'Misdirected Request',
        422 => 'Unprocessable Entity',
        423 => 'Locked',
        424 => 'Failed Dependency',
        425 => 'Too Early',
        426 => 'Upgrade Required',
        428 => 'Precondition Required',
        429 => 'Too Many Requests',
        431 => 'Request Header Fields Too Large',
        451 => 'Unavailable For Legal Reasons',
        # Server error responses
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported',
        506 => 'Variant Also Negotiates',
        507 => 'Insufficient Storage',
        508 => 'Loop Detected',
        510 => 'Not Extended',
        511 => 'Network Authentication Required'
      }.freeze

      def initialize(socket)
        @socket = socket
        warn(inspect)
      end

      # https://www.rubydoc.info/github/rack/rack/file/SPEC
      def call
        request_line_and_headers, content = @socket.read_async.split("\r\n\r\n")
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
          'rack.input' => StringIO.new(content.to_s),
          'rack.version' => [1, 3],
          'rack.errors' => STDERR,
          'rack.multithread' => false,
          'rack.multiprocess' => false,
          'rack.run_once' => false,
          'rack.url_scheme' => 'http'
        }

        request_line_and_headers.each do |str|
          key, value = str.split(': ')

          case key.upcase!
          when 'CONTENT-TYPE', 'CONTENT-LENGTH'
            env[key] = value
          else
            env["HTTP_#{key}"] = value
          end
        end

        status_code, response_headers, response_content = 
          if env['REQUEST_PATH'] == '/siege'
            [200, { 'Connection' => 'close' }, ['']]
          else
            Flump.app.call(env)
          end

        reason_phrase = REASON_PHRASES[status_code]

        default_headers = {
          'Server' => HTTP_SERVER,
          'Date' => Time.now.utc.strftime(HTTP_DATE)
        }

        raw_response_headers =
          default_headers.
          merge(response_headers).
          map { |k, v| "#{k}: #{v}" }.
          join("\r\n")

        raw_response_content = ''
        response_content.each { |it| raw_response_content += it }

        raw_response =
          "HTTP/1.1 #{status_code} #{reason_phrase}\r\n" \
          "#{raw_response_headers}\r\n" \
          "\r\n" \
          "#{raw_response_content}"

        @socket.write_async(raw_response)

        case response_headers['Connection']
        # when 'keep-alive' then call
        when 'upgrade' then WS::Client.new(@socket).read
        else @socket.close
        end
      rescue EOFError, Errno::ECONNRESET => @error
        warn(inspect)
        @socket.close
      end
    end
  end
end
