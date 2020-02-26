# frozen_string_literal: true

# require_relative 'pg_connection'

# module Flump
#   class PGConnectionPool
#     def initialize(size)
#       @size = size

#       @pool = Array.new(size) do
#         PG::Connection.new(dbname: 'flump', port: 5432)
#       end

#       @index = 0
#     end

#     def query(sql)
#       @index = @index % @size + 1
#       @pool[@index - 1].query(sql)
#     end
#   end
# end
