# frozen_string_literal: true

module Flump
  module Time
    def http_date
      now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
    end
  end

  ::Time.extend(Time)
end
