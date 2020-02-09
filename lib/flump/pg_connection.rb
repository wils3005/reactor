# frozen_string_literal: true

module Flump
  module PGConnection
    include Async

    def query_async(sql)
      setnonblocking(true)
      send_query(sql)
      _async { get_result }
    end
  end

  ::PG::Connection.include PGConnection if defined? ::PG::Connection
end
