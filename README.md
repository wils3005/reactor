# flump

A lightweight framework for building network applications in ruby.

```ruby
# my_flump.rb

require 'flump'

Flump::HTTP::Exchange.new('GET', '/') do |request|
  { status_code: 200 }
end

Flump.call

```
