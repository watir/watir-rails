module Watir
  class Browser
    alias_method :original_initialize, :initialize

    def initialize(*args)
      Rails.boot
      original_initialize *args
    end

    alias_method :original_goto, :goto

    def goto(url)
      url = "http://#{Rails.host}:#{Rails.port}#{url}" unless url =~ %r{^http://}i
      original_goto url
    end
  end
end

