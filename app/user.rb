# frozen_string_literal: true

get /\A\/user\z/ do
  sql = <<~SQL
    SELECT *
    FROM users
    ORDER BY random()
    LIMIT 1
  SQL

  result = PG::Connection.query_async(sql)
  body = { user: result.first }.to_json
  [200, { 'Content-Type' => Flump::HTTP::CONTENT_TYPE_JSON, 'Content-Length' => body.size }, body]
end
