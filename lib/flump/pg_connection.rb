# frozen_string_literal: true

require 'pg'

module Flump
  module PGConnection
    def query(sql)
      send_query(sql)
      socket_io.wait_readable
      result = get_result
      finish
      result
    end

    ::PG::Connection.include(self)
  end
end
