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
    before { ::Rails.application.env_config['action_dispatch.show_exceptions'] = false if defined?(::Rails) }

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

    it 'handles `Watir::Rails.ignore_exceptions?` changes in runtime' do
      Watir::Rails.ignore_exceptions = false
      expect { browser.goto('/tests/raise_error') }.to raise_error(RuntimeError)

      Watir::Rails.ignore_exceptions = true
      expect { browser.goto('/tests/raise_error') }.not_to raise_error

      Watir::Rails.ignore_exceptions = false
      expect { browser.goto('/tests/raise_error') }.to raise_error(RuntimeError)

      Watir::Rails.ignore_exceptions = true
      expect { browser.goto('/tests/raise_error') }.not_to raise_error
    end
  end

  context '#goto' do
    let(:driver) { browser.driver }
    let(:expected_url) { 'http://watir-rails.com:1234/some/path' }

    before { allow(Watir::Rails).to receive(:url).with('/some/path').and_return(expected_url) }

    it 'goes to Watir::Rails.url' do
      expect(driver).to receive(:to).with(expected_url)
      browser.goto('/some/path')
    end
  end

  context 'with real Rails app' do
    let(:browser) { Watir::Browser.new(:firefox, headless: true) }

    after { browser.close }

    it 'works' do
      browser.goto('/tests')
      expect(browser.text).to eq('Hello world!')
    end

    context 'with additional middleware' do
      before { Watir::Rails.app_path = "#{Watir::Rails.__send__(:app_path).sub(/\.ru\z/, '')}.auth.ru" }

      it 'uses middleware in config.ru' do
        browser.goto('/tests')
        expect(browser.alert).to be_present
        browser.alert.close
        Watir::Rails.host = "watir:rails@#{Watir::Rails.host}"
        browser.goto('/tests')
        expect(browser.alert).not_to be_present
        expect(browser.text).to eq('Hello world!')
      end
    end
  end
end
