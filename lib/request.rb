# frozen_string_literal: true

class Request
  def initialize(raw)
    headers, @body = raw.split("\r\n\r\n")
    headers = headers.split("\r\n")
    @method, @path, @version = headers.shift.split
    @headers = headers.map { _1.split(': ') }.to_h
  end
end
