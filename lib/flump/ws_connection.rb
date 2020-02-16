# frozen_string_literal: true

require_relative 'core_ext/io'

module Flump
  class WSConnection
    def initialize(tcp_socket)
      @tcp_socket = tcp_socket
    end

    def read_write
      first_byte, second_byte, *mask = @tcp_socket.read_async(6).bytes
      fin = first_byte & 0b10000000
      return @tcp_socket.close unless fin

      opcode = first_byte & 0b00001111
      return @tcp_socket.close if opcode == 8

      is_masked = second_byte & 0b10000000
      return @tcp_socket.close unless is_masked

      payload_size = second_byte & 0b01111111

      payload_size =
        if payload_size < 126
          payload_size
        elsif payload_size == 126
          @tcp_socket.read_async(2).unpack('n').first
        elsif payload_size == 127
          @tcp_socket.read_async(8).unpack('Q>').first
        else
          @tcp_socket.close
        end

      data = @tcp_socket.read_async(payload_size).bytes
      unmasked_data = data.each_with_index.map { |a,b| a ^ mask[b % 4] }
      request = unmasked_data.pack('C*').force_encoding('utf-8')
      response = "user#{object_id}: #{request}"
      output = [0b10000001, response.size, response]
      packed_response = output.pack("CCA#{response.size}")
      @tcp_socket.write_async(packed_response)
      read_write
    end

    def write_read
      # TODO
    end
  end
end
