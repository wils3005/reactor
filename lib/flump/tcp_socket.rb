# frozen_string_literal: true

module Flump
  module TCPSocket
    include Async

    attr_reader :websocket

    def read_write
      @websocket ? _read_write_websocket : _read_write_http
    rescue EOFError => @error
      self.fiber = nil
      ivars = instance_variables.each_with_object({}) do
        _2[_1.to_s] = instance_variable_get(_1)
      end

      warn("#{inspect} #{ivars}")
    end

    def write_read(method:, path:, host:, content: nil)
      request = HTTP.request(
        method: method,
        path: path,
        host: host,
        content: content
      )

      _async { write_nonblock(request) }
      response = _async { read_nonblock(MAX_PAYLOAD_SIZE) }
      close
      response
    end

    private

    def _read_write_websocket
      first_byte, second_byte, *mask =
        _async { read_nonblock(6) }.each_byte.to_a

      fin = first_byte & 0b10000000
      opcode = first_byte & 0b00001111
      is_masked = second_byte & 0b10000000
      payload_size = second_byte & 0b01111111
      raise "We don't support continuations" unless fin
      raise "We only support opcode 1" unless opcode == 1
      raise "All frames sent to a server should be masked according to the websocket spec" unless is_masked
      raise "We only support payloads < 126 bytes in length" unless payload_size < 126

      data = _async { read_nonblock(payload_size) }.each_byte.to_a
      unmasked_data = data.each_with_index.map { _1 ^ mask[_2 % 4] }
      request = unmasked_data.pack('C*').force_encoding('utf-8')

      response = "user#{object_id}: #{request}"
      output = [0b10000001, response.size, response]
      packed_response = output.pack("CCA#{response.size}")
      _async { write_nonblock(packed_response) }
      read_write
    end

    def _read_write_http
      raw = _async { read_nonblock(MAX_PAYLOAD_SIZE) }
      response = HTTPRequest.new(raw).response
      _async { write_nonblock(response.raw) }
      return close unless response.status_code == 101

      @websocket = true
      read_write
    end
  end

  ::TCPSocket.include TCPSocket
end
