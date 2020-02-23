# frozen_string_literal: true

require 'pg'

module Flump
  module PGConnection
    def query_async(sql)
      send_query(sql)
      socket_io.wait_readable unless socket_io.ready?
      query_async = get_result
      query_async
    end

    ::PG::Connection.include(self)
  end
end
