#---
# Excerpted from "dRuby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/sidruby for more book information.
#---
require 'rinda/ring'

DRb.start_service

ts = Rinda::RingFinger.primary
tuple = ts.read_all([:name, :Hello, DRbObject, nil]).first
if tuple.nil?
  puts "Hello: not found."
  exit(1)
end
hello = tuple[2]
puts hello.greeting