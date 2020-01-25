# frozen_string_literal: true

module Reactor
  def _reactor_accept
    accept_nonblock.register(Reactor::READ, :request)
  end
end
