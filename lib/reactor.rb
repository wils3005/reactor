# frozen_string_literal: true

puts __FILE__

class Reactor
  attr_reader :read, :write

  def initialize
    @read = []
    @write = []
  end

  def call
    loop { IO.select(@read, @write).flatten.each(&:reactor_callback) }
  end
end
