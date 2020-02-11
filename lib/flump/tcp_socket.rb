# frozen_string_literal: true

module Flump
  module TCPSocket
    attr_reader :websocket

    def read_write
      @websocket ? _read_write_websocket : _read_write_http
    rescue EOFError => @error
      @fiber = nil
      close
    end

    def write_read(method:, host:, path:, body: nil)
      @websocket ? _write_read_websocket : _write_read_http
    end

    private

    def _read_write_http
      raw_request = read_async
      exchange = HTTPExchange.new(raw_request)
      write_async(exchange.raw_response)
      return close if exchange.response_headers['Connection'] == 'close'

      @websocket = true if exchange.status_code == 101
      read_write
    rescue Errno::ECONNRESET => @error
      @fiber = nil
      close
    end

    def _write_read_http(method, host, path, body)
      body ||= "\r\n"

      raw_request =
        "#{method} #{path} HTTP/1.1\r\n" \
        "Host: #{host}\r\n" \
        "User-Agent: flump/0.1.0\r\n" \
        "Accept: */*\r\n" \
        "Connection: keep-alive\r\n" \
        "#{body}"

      write_async(raw_request)
      raw_response = read_async
      close
      raw_response
    end

    def _read_write_websocket
      first_byte, second_byte, *mask = read_async(6).bytes
      fin = first_byte & 0b10000000
      return close unless fin

      opcode = first_byte & 0b00001111
      return close if opcode == 8

      is_masked = second_byte & 0b10000000
      return close unless is_masked

      payload_size = second_byte & 0b01111111

      payload_size =
        if payload_size < 126
          payload_size
        elsif payload_size == 126
          read_async(2).unpack('n').first
        elsif payload_size == 127
          read_async(8).unpack('Q>').first
        else
          close
        end

      data = read_async(payload_size).bytes
      unmasked_data = data.each_with_index.map { _1 ^ mask[_2 % 4] }
      request = unmasked_data.pack('C*').force_encoding('utf-8')
      response = "user#{object_id}: #{request}"
      output = [0b10000001, response.size, response]
      packed_response = output.pack("CCA#{response.size}")
      write_async(packed_response)
      read_write
    end

    def _write_read_websocket; end
  end

  ::TCPSocket.include(TCPSocket)
end
