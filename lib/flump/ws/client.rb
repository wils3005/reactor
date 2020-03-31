# frozen_string_literal: true

require 'digest/bubblebabble'

module Flump
  module WS
    class Client
      @all = []

      class << self
        attr_reader :all
      end

      def initialize(socket)
        @socket = socket

        @user_name =
          Digest
          .bubblebabble(inspect)
          .split('-')
          .sample
          .capitalize

        message = "#{@user_name} joined #flump"
        WS::Client.all.each { |it| it.write(message) }
        WS::Client.all << self
      end

      def read
        first_byte, second_byte, *mask = @socket.read_async(6).bytes
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
            @socket.read_async(2).unpack('n').first
          elsif payload_size == 127
            @socket.read_async(8).unpack('Q>').first
          else
            return close
          end

        unmasked_data =
          @socket
          .read_async(payload_size)
          .bytes
          .each_with_index
          .map { |a,b| a ^ mask[b % 4] }

        message = unmasked_data.pack('C*').force_encoding('utf-8')
        str = "#{@user_name}: #{message}"
        WS::Client.all.each { |it| it.write(str) }
        read
      rescue => @error
        warn(inspect)
        close
      end

      def write(str)
        packed = [0b10000001, str.size, str].pack("CCA#{str.size}")
        @socket.write_async(packed)
      rescue => @error
        warn(inspect)
        close
      end

      def close
        WS::Client.all.delete(self)
        message = "#{@user_name} left #flump"
        WS::Client.all.each { |it| it.write(message) }
        @socket.close
      end
    end
  end
end
