module Watir
  # Reopened Watir::Browser class for working with Rails
  class Browser
    # @private
    alias_method :original_initialize, :initialize

    # Will start Rails instance for Watir automatically and then invoke the
    # original Watir::Browser#initialize method.
    def initialize(*args)
      Rails.boot
      original_initialize *args
    end

    # @private
    alias_method :original_goto, :goto

    # Opens the url with the browser instance.
    # Will add {Rails.host} and {Rails.port} to the url when path is specified.
    #
    # @example Open the regular url:
    #   browser.goto "http://google.com"
    #
    # @example Open the controller path:
    #   browser.goto home_path
    #
    # @param [String] url URL to be navigated to.
    def goto(url)
      url = "http://#{Rails.host}:#{Rails.port}#{url}" unless url =~ %r{^https?://}i || url == "about:blank"
      original_goto url
    end
  end
end

