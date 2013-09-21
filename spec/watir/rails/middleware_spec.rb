require "spec_helper"

describe Watir::Rails::Middleware do
  let(:app) { double("app") }
  let(:middleware) { described_class.new app }

  context "#call" do
    it "/__identify__ returns app id" do
      app.should_not_receive(:call)
      middleware.call("PATH_INFO" => "/__identify__").should == [200, {}, [app.object_id.to_s]]
    end

    it "other requests are forwarded to the app" do
      env = {}
      app.should_receive(:call).with(env)
      middleware.call(env)
    end

    it "errors are stored and re-raised" do
      error = RuntimeError.new
      app.stub(:call).and_raise error

      expect {
        middleware.call({})
      }.to raise_error(error)

      middleware.error.should == error
    end
  end
end
