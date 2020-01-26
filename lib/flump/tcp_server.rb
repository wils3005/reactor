# frozen_string_literal: true

module Flump
  module TCPServer
    def _reactor_callback
      Reactor::READ << accept_nonblock
    end
  end
end
