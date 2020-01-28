# frozen_string_literal: true

module Flump
  module Response
    RESPONSE =
      "HTTP/1.1 %<status_code>s %<reason_phrase>s\r\n" \
      "Connection: close\r\n" \
      "Date: %<date>s\r\n" \
      "%<content>s"

    CONTENT =
      "Content-Type: text/html; charset=utf-8\r\n" \
      "Content-Length: %<content_length>s\r\n" \
      "\r\n" \
      "%<content>s"

    INDEX = File.read('index.html')


    def serialize_response!
      return if defined? @response

      @content = "\r\n"
      @date = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      @status_code, @reason_phrase = status_code_with_reason_phrase

      format(
        RESPONSE,
        status_code: @status_code,
        reason_phrase: @reason_phrase,
        date: @date,
        content: @content
      )
    end

    private

    def status_code_with_reason_phrase
      case
      when bad_request? then [400, 'Bad Request']
      when version_not_supported? then [505, 'HTTP Version Not Supported']
      when not_implemented? then [501, 'Not Implemented']
      when payload_too_large? then [413, 'Payload Too Large']
      else
        # Router[@request.method][@request.path]
        index = format(INDEX, time: Time.now.utc)
        @content = format(CONTENT, content_length: index.length, content: index)
        [200, 'OK']
      end
    rescue
      [500, 'Internal Server Error']
    end
  end
end

# routes.merge!(
#   'CONNECT' => {},
#   'DELETE' => {
#     %r{\A/(\w+)\z} => :destroy,
#   },
#   'GET' => {
#     %r{\A/\z} => :index,
#     %r{\A/(\w+)\z} => :show,
#   },
#   'HEAD' => {},
#   'OPTIONS' => {},
#   'PATCH' => {
#     %r{\A/(\w+)\z} => :update_append,
#   },
#   'POST' => {},
#   'PUT' => {
#     %r{\A/(\w+)\z} => :idempotent_create_or_update,
#   },
#   'TRACE' => {}
# )

# @method = 'DELETE'
# @path = '/'

# routes[@method].find { |route, handler| @path =~ route } || :not_found

# POST /
#   create new record -
#   must provide all required fields, EXCEPT id
#   successful response MUST have body
#   NOT idempotent
# PUT /:id
#   create new OR completely overwrite existing record
#   must provide ALL required fields, INCLUDING id
#   rsuccessful esponse MUST NOT have body
#   idempotent
# PATCH /:id
#   update fields of existing record
#   must ONLY provide fields to be updated
#   successful response MUST have body
#   NOT idempotent
