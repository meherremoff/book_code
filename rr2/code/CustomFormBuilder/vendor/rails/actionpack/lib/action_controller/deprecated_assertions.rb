#---
# Excerpted from "Rails Recipes",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/rr2 for more book information.
#---
require 'test/unit'
require 'test/unit/assertions'
require 'rexml/document'

module Test #:nodoc:
  module Unit #:nodoc:
    module Assertions
      def assert_success(message=nil) #:nodoc:
        assert_response(:success, message)
      end

      def assert_redirect(message=nil) #:nodoc:
        assert_response(:redirect, message)
      end

      def assert_rendered_file(expected=nil, message=nil) #:nodoc:
        assert_template(expected, message)
      end

      # ensure that the session has an object with the specified name
      def assert_session_has(key=nil, message=nil) #:nodoc:
        msg = build_message(message, "<?> is not in the session <?>", key, @response.session)
        assert_block(msg) { @response.has_session_object?(key) }
      end

      # ensure that the session has no object with the specified name
      def assert_session_has_no(key=nil, message=nil) #:nodoc:
        msg = build_message(message, "<?> is in the session <?>", key, @response.session)
        assert_block(msg) { !@response.has_session_object?(key) }
      end

      def assert_session_equal(expected = nil, key = nil, message = nil) #:nodoc:
        msg = build_message(message, "<?> expected in session['?'] but was <?>", expected, key, @response.session[key])
        assert_block(msg) { expected == @response.session[key] }
      end

      # -- cookie assertions ---------------------------------------------------

      def assert_no_cookie(key = nil, message = nil) #:nodoc:
        actual = @response.cookies[key]
        msg = build_message(message, "<?> not expected in cookies['?']", actual, key)
        assert_block(msg) { actual.nil? or actual.empty? }
      end
    
      def assert_cookie_equal(expected = nil, key = nil, message = nil) #:nodoc:
        actual = @response.cookies[key]
        actual = actual.first if actual
        msg = build_message(message, "<?> expected in cookies['?'] but was <?>", expected, key, actual)
        assert_block(msg) { expected == actual }
      end
    
      # -- flash assertions ---------------------------------------------------

      # ensure that the flash has an object with the specified name
      def assert_flash_has(key=nil, message=nil) #:nodoc:
        msg = build_message(message, "<?> is not in the flash <?>", key, @response.flash)
        assert_block(msg) { @response.has_flash_object?(key) }
      end

      # ensure that the flash has no object with the specified name
      def assert_flash_has_no(key=nil, message=nil) #:nodoc:
        msg = build_message(message, "<?> is in the flash <?>", key, @response.flash)
        assert_block(msg) { !@response.has_flash_object?(key) }
      end

      # ensure the flash exists
      def assert_flash_exists(message=nil) #:nodoc:
        msg = build_message(message, "the flash does not exist <?>", @response.session['flash'] )
        assert_block(msg) { @response.has_flash? }
      end

      # ensure the flash does not exist
      def assert_flash_not_exists(message=nil) #:nodoc:
        msg = build_message(message, "the flash exists <?>", @response.flash)
        assert_block(msg) { !@response.has_flash? }
      end
    
      # ensure the flash is empty but existent
      def assert_flash_empty(message=nil) #:nodoc:
        msg = build_message(message, "the flash is not empty <?>", @response.flash)
        assert_block(msg) { !@response.has_flash_with_contents? }
      end

      # ensure the flash is not empty
      def assert_flash_not_empty(message=nil) #:nodoc:
        msg = build_message(message, "the flash is empty")
        assert_block(msg) { @response.has_flash_with_contents? }
      end
    
      def assert_flash_equal(expected = nil, key = nil, message = nil) #:nodoc:
        msg = build_message(message, "<?> expected in flash['?'] but was <?>", expected, key, @response.flash[key])
        assert_block(msg) { expected == @response.flash[key] }
      end
    

      # ensure our redirection url is an exact match
      def assert_redirect_url(url=nil, message=nil) #:nodoc:
        assert_redirect(message)
        msg = build_message(message, "<?> is not the redirected location <?>", url, @response.redirect_url)
        assert_block(msg) { @response.redirect_url == url }
      end

      # ensure our redirection url matches a pattern
      def assert_redirect_url_match(pattern=nil, message=nil) #:nodoc:
        assert_redirect(message)
        msg = build_message(message, "<?> was not found in the location: <?>", pattern, @response.redirect_url)
        assert_block(msg) { @response.redirect_url_match?(pattern) }
      end

    
      # -- template assertions ------------------------------------------------

      # ensure that a template object with the given name exists
      def assert_template_has(key=nil, message=nil) #:nodoc:
        msg = build_message(message, "<?> is not a template object", key )
        assert_block(msg) { @response.has_template_object?(key) }
      end

      # ensure that a template object with the given name does not exist
      def assert_template_has_no(key=nil,message=nil) #:nodoc:
        msg = build_message(message, "<?> is a template object <?>", key, @response.template_objects[key])
        assert_block(msg) { !@response.has_template_object?(key) }
      end

      # ensures that the object assigned to the template on +key+ is equal to +expected+ object.
      def assert_template_equal(expected = nil, key = nil, message = nil) #:nodoc:
        msg = build_message(message, "<?> expected in assigns['?'] but was <?>", expected, key, @response.template.assigns[key.to_s])
        assert_block(msg) { expected == @response.template.assigns[key.to_s] }
      end
      alias_method :assert_assigned_equal, :assert_template_equal

      # Asserts that the template returns the +expected+ string or array based on the XPath +expression+.
      # This will only work if the template rendered a valid XML document.
      def assert_template_xpath_match(expression=nil, expected=nil, message=nil) #:nodoc:
        xml, matches = REXML::Document.new(@response.body), []
        xml.elements.each(expression) { |e| matches << e.text }
        if matches.empty? then
          msg = build_message(message, "<?> not found in document", expression)
          flunk(msg)
          return
        elsif matches.length < 2 then
          matches = matches.first
        end

        msg = build_message(message, "<?> found <?>, not <?>", expression, matches, expected)
        assert_block(msg) { matches == expected }
      end

      # Assert the template object with the given name is an Active Record descendant and is valid.
      def assert_valid_record(key = nil, message = nil) #:nodoc:
        record = find_record_in_template(key)
        msg = build_message(message, "Active Record is invalid <?>)", record.errors.full_messages)
        assert_block(msg) { record.valid? }
      end

      # Assert the template object with the given name is an Active Record descendant and is invalid.
      def assert_invalid_record(key = nil, message = nil) #:nodoc:
        record = find_record_in_template(key)
        msg = build_message(message, "Active Record is valid)")
        assert_block(msg) { !record.valid? }
      end

      # Assert the template object with the given name is an Active Record descendant and the specified column(s) are valid.
      def assert_valid_column_on_record(key = nil, columns = "", message = nil) #:nodoc:
        record = find_record_in_template(key)
        record.send(:validate)

        cols = glue_columns(columns)
        cols.delete_if { |col| !record.errors.invalid?(col) }
        msg = build_message(message, "Active Record has invalid columns <?>)", cols.join(",") )
        assert_block(msg) { cols.empty? }
      end

      # Assert the template object with the given name is an Active Record descendant and the specified column(s) are invalid.
      def assert_invalid_column_on_record(key = nil, columns = "", message = nil) #:nodoc:
        record = find_record_in_template(key)
        record.send(:validate)

        cols = glue_columns(columns)
        cols.delete_if { |col| record.errors.invalid?(col) }
        msg = build_message(message, "Active Record has valid columns <?>)", cols.join(",") )
        assert_block(msg) { cols.empty? }
      end

      private
        def glue_columns(columns)
          cols = []
          cols << columns if columns.class == String
          cols += columns if columns.class == Array
          cols
        end

        def find_record_in_template(key = nil)
          assert_template_has(key)
          record = @response.template_objects[key]

          assert_not_nil(record)
          assert_kind_of ActiveRecord::Base, record

          return record
        end      
    end
  end
end