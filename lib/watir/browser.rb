module Watir
  # Reopened Watir::Browser class for working with Rails
  class Browser
    # @private
    alias_method :original_initialize, :initialize

    # Will start Rails instance for Watir automatically and then invoke the
    # original Watir::Browser#initialize method.
    def initialize(*args)
      initialize_rails_with_watir *args
    end

    # Opens the url with the browser instance.
    # Will add {Rails.host} and {Rails.port} to the url when path is specified.
    #
    # @example Go to the regular url:
    #   browser.goto "http://google.com"
    #
    # @example Go to the controller path:
    #   browser.goto home_path
    #
    # @param [String] url URL to be navigated to.
    def goto(url)
      url = "http://#{Rails.host}:#{Rails.port}#{url}" unless url =~ %r{^(about|data|https?):}i
      _new_goto url
    end

    private

    def override_and_preserve_original_methods(*method_names, &block)
      method_names.each do |method_name|
        next if respond_to? "_original_#{method_name}", true
        self.class.send :alias_method, "_original_#{method_name}", method_name
      end

      result = block.call

      method_names.each do |method_name|
        next if respond_to? "_new_#{method_name}", true
        self.class.send :alias_method, "_new_#{method_name}", method_name

        self.class.send :define_method, method_name do |*args|
          send("_original_#{method_name}", *args)
          #send("_new_#{method_name}", *args)
        end
      end

      result
    end

    def initialize_rails_with_watir(*args)
      Rails.boot
      override_and_preserve_original_methods(:goto) { original_initialize *args }
      add_exception_checker unless Rails.ignore_exceptions?
    end

    def add_exception_checker
      after_hooks.add do
        if error = Rails.error
          Rails.error = nil
          raise error
        end
      end
    end
  end
end

