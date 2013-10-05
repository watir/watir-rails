# Needed to simulate watir gem.

module Watir
  class Browser
    def initialize(*args)
      require File.expand_path("fake_browser_with_goto", File.dirname(__FILE__))
    end
  end
end
