# frozen_string_literal: true

module Flump
  module TCPServer
    def flump
      Reactor::READ << accept_nonblock
    end
  end
end
