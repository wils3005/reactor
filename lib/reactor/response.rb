# frozen_string_literal: true

module Reactor
  def _reactor_response
    write_nonblock(Response.new(@request))
    close_write
    unregister
  end
end
