# frozen_string_literal: true

require 'pg'

module Flump
  module PG
    module Connection
      module ClassMethods
        def query_async(sql)
          new(dbname: DBNAME).query_async(sql)
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
    end

    ::PG::Connection.include(Connection)
  end
end
