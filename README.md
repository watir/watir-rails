# Watir::Rails
[![Gem Version](https://badge.fury.io/rb/watir-rails.png)](http://badge.fury.io/rb/watir-rails)

This gem adds the [Watir](http://github.com/watir/watir) usage support when writing integration tests in Rails.


## Installation

Add this code to your Gemfile:

```ruby
group :test do
  gem 'watir-rails'
end
```

## Usage

Just use Watir like you've always done in your requests/integration tests:

```ruby
browser = Watir::Browser.new
browser.goto home_path
browser.text_field(name: "first").set "Jarmo"
browser.text_field(name: "last").set  "Pertman"
browser.button(name: "sign_in").click
```

### Ignore Rails Exceptions

By default, exceptions raised by Rails application will be re-raised in your tests making them to fail.

This feature is only enabled when `config.action_dispatch.show_exceptions` is set to `false` in your Rails configuration.

You can disable it in watir-rails by ignoring exceptions:

```ruby
Watir::Rails.ignore_exceptions = false
```

## Limitations

* Watir-Rails works currently only with the [Watir-WebDriver](http://github.com/watir/watir-webdriver) and not with
the [Watir-Classic](http://github.com/watir/watir-classic) due to the problems of running a server
in the separate thread when WIN32OLE is used.
The problem is probably caused by the fact that [WIN32OLE overwrites Thread#initialize](https://github.com/ruby/ruby/blob/trunk/test/ruby/test_thread.rb#L607).

* When using Rails path/url helpers in your tests then always use path instead of url methods, because latter won't work!


## Contributors

* [Jarmo Pertman](https://github.com/jarmo)
* [Alex Rodionov](https://github.com/p0deje)


## License

See [LICENSE](https://github.com/watir/watir-rails/blob/master/LICENSE).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
