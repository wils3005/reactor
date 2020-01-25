# frozen_string_literal: true

module Reactor
  def _reactor_request
    @request = read_nonblock(MAXLEN)
    close_read
    unregister
    register(Reactor::WRITE, :response)
  end
end
