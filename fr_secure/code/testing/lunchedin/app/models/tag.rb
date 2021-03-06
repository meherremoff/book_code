#---
# Excerpted from "Security on Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_secure for more book information.
#---
class Tag < ActiveRecord::Base
  has_and_belongs_to_many :venues
  
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[a-zA-Z0-9 ]*\Z/
  
  def on(dest)
    dest.tags << self
  end
end
