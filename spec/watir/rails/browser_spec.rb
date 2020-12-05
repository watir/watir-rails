require 'spec_helper'

describe Watir::Browser do
  let(:browser) { Watir::Browser.new(:dummy) }

  before { allow(Watir::Rails).to receive_messages(ignore_exceptions?: true) }

  context '#initialize' do
    it 'starts Rails before opening the browser' do
      expect(Watir::Rails).to receive(:boot)
      expect_any_instance_of(Watir::Browser).to receive(:_original_initialize).and_call_original

      browser
    end

    it 'does not add Exception hook when exceptions are ignored' do
      allow(Watir::Rails).to receive_messages(ignore_exceptions?: true, boot: nil)

      expect_any_instance_of(Watir::Browser).not_to receive(:add_exception_hook)

      browser
    end

    it 'adds Exception hook when exceptions are not ignored' do
      allow(Watir::Rails).to receive_messages(ignore_exceptions?: false, boot: nil)

      expect_any_instance_of(Watir::Browser).to receive(:add_exception_hook)

      browser
    end
  end

  context '#goto' do
    before do
      allow(Watir::Rails).to receive_messages(host: 'foo.com', port: 42, boot: nil)
    end

    it 'uses Rails for paths specified as an url' do
      expect(browser).to receive(:_original_goto).with('http://foo.com:42/foo/bar')
      browser.goto('/foo/bar')
    end

    it 'does not alter url with http:// scheme' do
      expect(browser).to receive(:_original_goto).with('http://baz.org/lol')
      browser.goto('http://baz.org/lol')
    end

    it 'does not alter url with https:// scheme' do
      expect(browser).to receive(:_original_goto).with('https://baz.org/lol')
      browser.goto('https://baz.org/lol')
    end

    it 'does not alter about:urls' do
      expect(browser).to receive(:_original_goto).with('about:url')
      browser.goto('about:url')
    end

    it 'does not alter data:urls' do
      expect(browser).to receive(:_original_goto).with('data:url')
      browser.goto('data:url')
    end

    it 'alters the unknown urls' do
      expect(browser).to receive(:_original_goto).with('http://foo.com:42/xxx:yyy')
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
