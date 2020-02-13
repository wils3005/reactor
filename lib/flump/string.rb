# frozen_string_literal: true

require 'digest/sha1'

module Flump
  module String
    def base64digest
      Digest::SHA1.base64digest(self)
    end
  end

  ::String.include(String)
end
