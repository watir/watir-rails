module Watir
  # Reopened Watir::Browser class for working with Hanami
  class Browser
    # @private
    alias_method :_original_initialize, :initialize

    # Will start Hanami instance for Watir automatically and then invoke the
    # original Watir::Browser#initialize method.
    def initialize(*args)
      Hanami.boot
      _original_initialize *args
    end

    # @private
    alias_method :_original_goto, :goto

    # Opens the url with the browser instance.
    # Will add {Hanami.host} and {Hanami.port} to the url when path is specified.
    #
    # @example Go to the regular url:
    #   browser.goto "http://google.com"
    #
    # @example Go to the controller path:
    #   browser.goto home_path
    #
    # @param [String] url URL to be navigated to.
    def goto(url)
      url = "http://#{Hanami.host}:#{Hanami.port}#{url}" unless url =~ %r{^(about|data|https?):}i
      _original_goto url
    end
  end
end

