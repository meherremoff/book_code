#---
# Excerpted from "Rails Recipes",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/rr2 for more book information.
#---
if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

require 'rails/generators'
require 'rails/generators/rails/plugin_new/plugin_new_generator'

Rails::Generators::PluginNewGenerator.start