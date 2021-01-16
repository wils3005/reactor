# frozen_string_literal: true

require 'socket'
require_relative 'flump/configuration'
require_relative 'flump/http_exchange'
require_relative 'flump/io'
require_relative 'flump/tcp_server'
require_relative 'rack/handler/flump'

module Flump
  VERSION = '0.1.0'

  def self.call(...)
    config = Configuration.new(...)

    config.logger.info("flump listening at http://#{config.host}:#{config.port}!")

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    loop(&IO.method(:resume))
  end
end
