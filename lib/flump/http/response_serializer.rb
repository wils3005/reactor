# frozen_string_literal: true

module Flump
  module HTTP
    module ResponseSerializer
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

      def self.call(status_code, headers, rack_body)
        reason_phrase = REASON_PHRASES[status_code]

        headers =
          default_headers.
          merge(headers).
          map { |k, v| "#{k}: #{v}" }.
          join("\r\n")

        body = ''
        rack_body.each { |it| body += it }

        "HTTP/1.1 #{status_code} #{reason_phrase}\r\n" \
        "#{headers}\r\n" \
        "\r\n" \
        "#{body}"
      end

      def self.default_headers
        {
          'Server' => HTTP_SERVER,
          'Date' => Time.now.utc.strftime(HTTP_DATE),
          'Connection' => 'close'
        }
      end
    end
  end
end