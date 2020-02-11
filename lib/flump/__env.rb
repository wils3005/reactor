# frozen_string_literal: true

module Flump
  module ENV
    def self.extended(mod)
      env = File.join(Dir.pwd, '.env')
      return unless File.exists?(env)

      hsh =
        File.
        read(env).
        split("\n").
        reject { _1 =~ /^\s*#/ }.
        map { _1.split('=') }.
        to_h

      mod.merge!(hsh)

      env_sample = File.join(Dir.pwd, '.env.sample')
      return unless File.exists?(env_sample)

      env_sample_keys =
        File.
        read(env_sample).
        split("\n").
        map { _1[/^\w+/] }

      missing_keys = (env_sample_keys - mod.keys)
      return if missing_keys.empty?

      abort "ENV values not set: #{missing_keys}"
    end
  end

  ::ENV.extend(ENV)
end
