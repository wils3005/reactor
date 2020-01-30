# frozen_string_literal: true

INDEX = File.read("#{__dir__}/index.html")

get /\A\/\z/ do
  format INDEX, time: Time.now.utc
end
