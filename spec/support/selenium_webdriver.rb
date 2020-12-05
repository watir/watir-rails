module Watir
  module Rails
    module Dummy
      # Null object that acts as a test selenium driver
      class Driver
        def method_missing(*_args, **_kwargs, &_block) # rubocop:disable Style/MethodMissingSuper
          self
        end

        def respond_to_missing?(_method_name, _include_private = false)
          true
        end
      end
    end
  end
end

module Monkey
  module Selenium
    module WebDriver
      module Remote
        # Dummy capabilities for our dummy selenium driver
        module Capabilities
          def dummy(opts = {})
            new({browser_name: 'dummy'}.merge(opts))
          end
        end
      end

      # Monkeypatch to return our dummy driver when `:dummy` browser is requested
      module Driver
        def for(browser, *_args, **_kwargs)
          return Watir::Rails::Dummy::Driver.new if browser == :dummy

          super
        end
      end
    end
  end
end

Selenium::WebDriver::Remote::Capabilities.extend(Monkey::Selenium::WebDriver::Remote::Capabilities)
Selenium::WebDriver::Driver.singleton_class.prepend(Monkey::Selenium::WebDriver::Driver)
