# frozen_string_literal: true

require_relative '../application'
require_relative '../http_request'
require_relative 'binding'

module Flump
  module UNIXServer
    def resume
      Fiber.new do
        unix_socket = accept_nonblock
        raw_req = unix_socket.read_async
        req = HTTPRequest.parse(raw_req)
        res = Application.new(req).response
        unix_socket.write_async(res)
        # return WSConnection.new(@tcp_socket).read_write if response.status_code == 101
        unix_socket.close
      end.resume
    rescue => error
      binding.stderr
    end

    ::UNIXServer.include(self)
  end
end
