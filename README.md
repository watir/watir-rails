# Watir::Rails
[![Gem Version](https://badge.fury.io/rb/watir-rails.png)](http://badge.fury.io/rb/watir-rails)
[![Build Status](https://api.travis-ci.org/watir/watir-rails.png)](http://travis-ci.org/watir/watir-rails)
[![Coverage](https://coveralls.io/repos/watir/watir-rails/badge.png?branch=master)](https://coveralls.io/r/watir/watir-rails)

This gem makes [Watir](https://github.com/watir/watir) work with Rails.


## Installation

Add this code to your Gemfile:

```ruby
group :test do
  gem "watir-rails"
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
Watir::Rails.ignore_exceptions = true
```

## Limitations

* When using Rails path/url helpers in your tests then always use path instead of url methods, because latter won't work!


## Contributors

* [Jarmo Pertman](https://github.com/jarmo)
* [Alex Rodionov](https://github.com/p0deje)


## License

See [LICENSE](https://github.com/watir/watir-rails/blob/master/LICENSE).
