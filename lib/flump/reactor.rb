# frozen_string_literal: true

module Flump
  module Reactor
    READ = []
    WRITE = []
    ERROR = []

    def reactor
      trap('INT') { return }
      loop { ::IO.select(READ, WRITE, ERROR).flatten.each(&:flump) }
    end
  end
end
