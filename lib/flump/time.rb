# frozen_string_literal: true

module Flump
  module Time
    def date_header
      now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
    end
  end
end
