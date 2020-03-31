# frozen_string_literal: true

require 'socket'
require_relative 'flump/application'
require_relative 'flump/http'
require_relative 'flump/io'
require_relative 'flump/selector'
require_relative 'flump/ws'

module Flump
  VERSION = '0.1.0'

  @pid = Process.pid

  class << self
    attr_reader :app, :host, :port
  end

  def self.call(app, **options)
    @app = app
    @host = options[:host] || ENV.fetch('HOST') { 'localhost' }
    @port = options[:port] || ENV.fetch('PORT') { 65432 }
    @sock = options[:sock] || ENV.fetch('SOCK') { '/home/flump/tmp/flump.sock' }
    FileUtils.rm(@sock) if File.exists?(@sock)
    server = TCPServer.new(@host, @port)
    # server = UNIXServer.new(@sock)
    # FileUtils.chmod('ugo=rw', @sock)
    HTTP::Server.new(server)
    Selector.run

    # warn "#{@pid}/flump listening at http://#{@host}:#{@port}!"
    warn "#{@pid}/flump listening at unix:#{@sock}!"

    trap 'INT' do
      warn "\nShutting down...\n"
      exit
    end

    sleep
  end
end
