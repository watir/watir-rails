require "spec_helper"

describe Watir::Browser do
  before { Watir::Rails.stub(ignore_exceptions?: true) }

  context "#initialize" do
    it "starts Rails before opening the browser" do
      Watir::Rails.should_receive(:boot)
      Watir::Browser.any_instance.should_receive(:original_initialize).and_call_original

      Watir::Browser.new
    end

    it "does not add Exception checker when exceptions are ignored" do
      Watir::Rails.stub(ignore_exceptions?: true, boot: nil)

      Watir::Browser.any_instance.should_not_receive(:add_exception_checker)
      Watir::Browser.new
    end

    it "adds Exception checker when exceptions are not ignored" do
      Watir::Rails.stub(ignore_exceptions?: false, boot: nil)

      Watir::Browser.any_instance.should_receive(:add_exception_checker)
      Watir::Browser.new
    end
  end

  context "#goto" do
    before do
      Watir::Rails.stub(host: "foo.com", port: 42, boot: nil)
    end

    let(:browser) { Watir::Browser.new }

    it "uses Rails for paths specified as an url" do
      browser.should_receive(:_new_goto).with("http://foo.com:42/foo/bar")
      browser.goto("/foo/bar")
    end

    it "does not alter url with http:// scheme" do
      browser.should_receive(:_new_goto).with("http://baz.org/lol")
      browser.goto("http://baz.org/lol")
    end

    it "does not alter url with https:// scheme" do
      browser.should_receive(:_new_goto).with("https://baz.org/lol")
      browser.goto("https://baz.org/lol")
    end

    it "does not alter about:urls" do
      browser.should_receive(:_new_goto).with("about:url")
      browser.goto("about:url")
    end

    it "does not alter data:urls" do
      browser.should_receive(:_new_goto).with("data:url")
      browser.goto("data:url")
    end

    it "alters the unknown urls" do
      browser.should_receive(:_new_goto).with("http://foo.com:42/xxx:yyy")
      browser.goto("http://foo.com:42/xxx:yyy")
    end
  end
end
