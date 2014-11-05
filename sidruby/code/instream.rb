#---
# Excerpted from "dRuby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/sidruby for more book information.
#---
class INStream 
  def initialize(ts, name)
    @ts = ts 
    @name = name 
    @head = 0
  end
  
  def take 
    tuple = @ts.take([@name, @head, nil]) 
    @head += 1 
    return tuple[2]
  end 
end