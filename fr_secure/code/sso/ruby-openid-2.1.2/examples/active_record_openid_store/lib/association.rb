#---
# Excerpted from "Security on Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_secure for more book information.
#---
require 'openid/association'
require 'time'

class Association < ActiveRecord::Base
  set_table_name 'open_id_associations'
  def from_record
    OpenID::Association.new(handle, secret, Time.at(issued), lifetime, assoc_type)
  end
end

