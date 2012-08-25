# Watir::Rails

This gem adds the [Watir](http://github.com/watir/watir) usage support when writing integration tests in Rails.

## Installation

Add this code to your Gemfile:

    group :test do
      gem 'watir-rails'
    end

## Usage

Just use Watir like you've always done in your requests/integration tests:

    browser = Watir::Browser.new
    browser.goto home_path # always use the *_path methods instead of the *_url methods!
    browser.text_field(name: "first").set "Jarmo"
    browser.text_field(name: "last").set  "Pertman"
    browser.button(name: "sign_in").click

## Limitations

* Watir-Rails works currently only with [Watir-WebDriver](http://github.com/watir/watir-webdriver) and not with
the [Watir-Classic](http://github.com/watir/watir-classic) due to the problems of running a server
in the separate thread when WIN32OLE is used.
The problem is probably caused by the fact that [WIN32OLE overwrites Thread#initialize](https://github.com/ruby/ruby/blob/trunk/test/ruby/test_thread.rb#L607).

* When using Rails path/url helpers in your tests then always use path instead of url methods.

## License

See [LICENSE](https://github.com/watir/watir-rails/blob/master/LICENSE).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
