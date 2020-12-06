module Watir
  module Rails
    # Watir::Browser extension to use Watir::Rails application run by
    module Browser
      # Will start Rails instance for Watir automatically and then invoke the
      # original Watir::Browser#initialize method.
      def initialize(*args)
        Rails.boot
        super
        add_exception_hook unless Rails.ignore_exceptions?
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
        url = "http://#{Rails.host}:#{Rails.port}#{url}" unless url =~ /^(about|data|https?):/i
        super(url)
      end

      private

      def add_exception_hook
        after_hooks.add do
          if (error = Rails.error)
            Rails.error = nil
            raise error
          end
        end
      end
    end
  end
end

Watir::Browser.prepend(Watir::Rails::Browser)
