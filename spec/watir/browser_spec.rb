require "spec_helper"

describe Watir::Browser do
  context "#initialize" do
    before { Watir::Rails.stub(ignore_exceptions?: true) }

    it "starts Rails before opening the browser" do
      Watir::Rails.should_receive(:boot)
      Watir::Browser.any_instance.should_receive(:original_initialize)

      Watir::Browser.new :foo
    end

    it "does not add Exception checker when exceptions are ignored" do
      Watir::Rails.stub(ignore_exceptions?: true, boot: nil)
      Watir::Browser.any_instance.stub(original_initialize: nil)

      Watir::Browser.any_instance.should_not_receive(:add_exception_checker)
      Watir::Browser.new :foo      
    end

    it "adds Exception checker when exceptions are not ignored" do
      Watir::Rails.stub(ignore_exceptions?: false, boot: nil)
      Watir::Browser.any_instance.stub(original_initialize: nil)

      Watir::Browser.any_instance.should_receive(:add_exception_checker)
      Watir::Browser.new :foo      
    end
  end

  context "#goto" do
    before do
      Watir::Rails.stub(host: "foo.com", port: 42)
      Watir::Browser.any_instance.stub(:initialize_rails_with_watir).and_return(nil)
    end

    let(:browser) { Watir::Browser.new }

    it "uses Rails for paths specified as an url" do
      browser.should_receive(:original_goto).with("http://foo.com:42/foo/bar")
      browser.goto("/foo/bar")
    end

    it "does not alter url with http:// scheme" do
      browser.should_receive(:original_goto).with("http://baz.org/lol")
      browser.goto("http://baz.org/lol")
    end

    it "does not alter url with https:// scheme" do
      browser.should_receive(:original_goto).with("https://baz.org/lol")
      browser.goto("https://baz.org/lol")
    end

    it "does not alter about:urls" do
      browser.should_receive(:original_goto).with("about:url")
      browser.goto("about:url")
    end

    it "does not alter data:urls" do
      browser.should_receive(:original_goto).with("data:url")
      browser.goto("data:url")
    end

    it "alters the unknown urls" do
      browser.should_receive(:original_goto).with("http://foo.com:42/xxx:yyy")
      browser.goto("http://foo.com:42/xxx:yyy")
    end
  end
end
