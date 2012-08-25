# Watir::Rails

This gem adds the [Watir](http://github.com/watir/watir) usage support when writing integration tests in Rails.

## Installation

Add this code to your Gemfile:

    group :test do
      gem 'watir-rails'
    end

## Limitations

watir-rails works currently only with [Watir-WebDriver](http://github.com/watir/watir-webdriver) and not with
the [Watir-Classic](http://github.com/watir/watir-classic) due to the problems of running a server
in the separate thread when WIN32OLE is used.
The problem is probably caused by the fact that [WIN32OLE overwrites Thread#initialize](https://github.com/ruby/ruby/blob/trunk/test/ruby/test_thread.rb#L607).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
