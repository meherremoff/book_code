#---
# Excerpted from "dRuby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/sidruby for more book information.
#---
class Stream 
  def initialize(ts, name)
    @ts = ts 
    @name = name 
    @ts.write([name, 'tail', 0])
  end 
  attr_reader :name
  def write(value) 
    tuple = @ts.take([name, 'tail', nil]) 
    tail = tuple[2] + 1 
    @ts.write([name, tail, value]) 
    @ts.write([name, 'tail', tail])
  end 
end
