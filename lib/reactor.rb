# frozen_string_literal: true

puts __FILE__

module Reactor
  READ = []
  WRITE = []
  ERROR = []

  def self.call
    loop { IO.select(READ, WRITE, ERROR).flatten.each(&:resume) }
  end
end
