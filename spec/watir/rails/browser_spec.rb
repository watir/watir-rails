require 'spec_helper'

describe Watir::Rails::Browser do
  let(:browser) { Watir::Browser.new(:dummy) }

  context '#initialize' do
    it 'starts Rails before opening the browser' do
      expect(Watir::Rails).to receive(:boot).ordered.and_call_original
      expect(Selenium::WebDriver::Driver).to receive(:for).with(:dummy, any_args).ordered.and_call_original

      browser
    end
  end

  context 'after_hooks' do
    before { ::Rails.application.env_config['action_dispatch.show_exceptions'] = false }

    it 'does not add Exception hook when exceptions are ignored' do
      Watir::Rails.ignore_exceptions = true

      expect { browser.goto('/tests/raise_error') }.not_to raise_error
      expect(Watir::Rails.error).to be_a(RuntimeError).and have_attributes(message: 'watir-rails test message')
    end

    it 'adds Exception hook when exceptions are not ignored' do
      Watir::Rails.ignore_exceptions = false

      browser.goto('/tests')
      expect(Watir::Rails.error).to be_nil

      expect { browser.goto('/tests/raise_error') }.to raise_error(RuntimeError, 'watir-rails test message')
      expect(Watir::Rails.error).to be_nil
    end
  end

  context '#goto' do
    let(:driver) { browser.driver }

    before do
      Watir::Rails.host = 'foo.com'
      allow(Watir::Rails).to receive(:port).and_return(42)
    end

    it 'uses Rails for paths specified as an url' do
      expect(driver).to receive(:to).with('http://foo.com:42/foo/bar')
      browser.goto('/foo/bar')
    end

    it 'does not alter url with http:// scheme' do
      expect(driver).to receive(:to).with('http://baz.org/lol')
      browser.goto('http://baz.org/lol')
    end

    it 'does not alter url with https:// scheme' do
      expect(driver).to receive(:to).with('https://baz.org/lol')
      browser.goto('https://baz.org/lol')
    end

    it 'does not alter about:urls' do
      expect(driver).to receive(:to).with('about:url')
      browser.goto('about:url')
    end

    it 'does not alter data:urls' do
      expect(driver).to receive(:to).with('data:url')
      browser.goto('data:url')
    end

    it 'alters the unknown urls' do
      expect(driver).to receive(:to).with('http://foo.com:42/xxx:yyy')
      browser.goto('http://foo.com:42/xxx:yyy')
    end
  end

  context 'with real Rails app' do
    let(:browser) { Watir::Browser.new(:firefox, headless: true) }

    after { browser.close }

    it 'works' do
      browser.goto('/tests')
      expect(browser.text).to eq('Hello world!')
    end
  end
end
