# Watir::Hanami
[![Gem Version](https://badge.fury.io/rb/watir-hanami.png)](http://badge.fury.io/rb/watir-hanami)
[![Build Status](https://api.travis-ci.org/mjacobus/watir-hanami.png)](http://travis-ci.org/mjacobus/watir-hanami)
[![Coverage](https://coveralls.io/repos/mjacobus/watir-hanami/badge.png?branch=master)](https://coveralls.io/r/mjacobus/watir-hanami)

This gem makes [Watir](https://github.com/watir/watir) work with Hanami.

## Installation

Add this code to your Gemfile:

```ruby
group :test do
  gem "watir-hanami"
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

## Limitations

* This is a [quick] adaptation of [watir-rails](https://github.com/watir/watir-rails). All the heavy lifting was done by those folks.


## Contributors

* [Jarmo Pertman](https://github.com/jarmo)
* [Alex Rodionov](https://github.com/p0deje)
* [Marcelo Jacobus](https://github.com/mjacobus)


## License

See [LICENSE](https://github.com/mjacobus/watir-hanami/blob/master/LICENSE).
