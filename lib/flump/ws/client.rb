# frozen_string_literal: true

module Flump
  module WS
    class Client
      def initialize(socket)
        @socket = socket
      end

      def call
        first_byte, second_byte, *mask = @socket.read_async(6).bytes
        fin = first_byte & 0b10000000
        return @socket.close unless fin

        opcode = first_byte & 0b00001111
        return @socket.close if opcode == 8

        is_masked = second_byte & 0b10000000
        return @socket.close unless is_masked

        payload_size = second_byte & 0b01111111

        payload_size =
          if payload_size < 126
            payload_size
          elsif payload_size == 126
            @socket.read_async(2).unpack('n').first
          elsif payload_size == 127
            @socket.read_async(8).unpack('Q>').first
          else
            @socket.close
          end

        data = @socket.read_async(payload_size).bytes
        unmasked_data = data.each_with_index.map { |a,b| a ^ mask[b % 4] }
        request = unmasked_data.pack('C*').force_encoding('utf-8')

        # application websocket logic here
        response = "user#{object_id}: #{request}"
        output = [0b10000001, response.size, response]
        packed_response = output.pack("CCA#{response.size}")
        @socket.write_async(packed_response)

        call
      end
    end
  end
end
