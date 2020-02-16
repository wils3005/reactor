# frozen_string_literal: true

require 'pg'
require_relative 'io'

module Flump
  module PGConnection
    module ClassMethods
      @pg_connection_config =
        ENV.
        fetch('PG_CONNECTION_CONFIG').
        split(';').
        map { |a| a.split('=') }.
        to_h

      def query_async(sql)
        new(@pg_connection_config).query_async(sql)
      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def query_async(sql)
      send_query(sql)
      socket_io.wait_readable! unless socket_io.ready?
      query_async = get_result
      close
      query_async
    end

    ::PG::Connection.include(self)
  end
end
