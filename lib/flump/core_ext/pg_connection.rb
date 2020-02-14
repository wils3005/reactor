# frozen_string_literal: true

require 'pg'

module Flump
  module PGConnection
    module ClassMethods
      def query_async(sql)
        new(dbname: ENV.fetch('DBNAME')).query_async(sql)
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
