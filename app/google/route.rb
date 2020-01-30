# frozen_string_literal: true

get /\A\/google\z/ do
  fiber = Fiber.new do
    Reactor::READ << TCPSocket.new('www.google.ca', 80)
  end

  # i need the result value eventually.  this has to be a fiber
  'ok'
end
