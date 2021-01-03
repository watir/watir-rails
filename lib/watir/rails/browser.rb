require 'watir'

module Watir
  module Rails
    # Watir::Browser extension to use Watir::Rails application run by
    module Browser
      # Will start Rails instance for Watir automatically and then invoke the
      # original Watir::Browser#initialize method.
      def initialize(*args)
        Rails.boot
        super
        add_exception_hook
      end

      # Opens the url or Rails app's under test path with the browser instance.
      #
      # @see Watir::Rails.url
      #
      # @param [String] url URL to be navigated to.
      def goto(url)
        super(Rails.url(url))
      end

      private

      def add_exception_hook
        after_hooks.add do
          next if Watir::Rails.ignore_exceptions?
          next unless (error = Watir::Rails.error)

          Watir::Rails.error = nil
          raise error
        end
      end
    end
  end
end

Watir::Browser.prepend(Watir::Rails::Browser)
