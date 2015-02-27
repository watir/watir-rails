require "spec_helper"

describe Watir::Rails do
  before do
    described_class.stub(:warn)
    described_class.ignore_exceptions = nil
    described_class.instance_eval { @middleware = @port = @server_thread = @host = @app = nil }
  end

  context ".boot" do
    it "starts the server unless already running" do
      described_class.stub(app: double("app"), find_available_port: 42)
      described_class.should_receive(:running?).twice.and_return(false, true)
      described_class.should_receive(:run_default_server).once

      described_class.boot
    end

    it "does nothing if server is already running" do
      described_class.stub(app: double("app"), find_available_port: 42)
      described_class.should_receive(:running?).once.and_return(true)
      described_class.should_not_receive(:run_default_server)

      described_class.boot
    end

    it "raises an error if Rails won't boot with timeout" do
      described_class.stub(app: double("app"), find_available_port: 42, boot_timeout: 0.01)
      described_class.should_receive(:running?).at_least(:twice).and_return(false)
      described_class.should_receive(:run_default_server)

      expect {
        described_class.boot
      }.to raise_error(Timeout::Error)
    end
  end

  context ".host" do
    it "@host if specified" do
      described_class.host = "my_host"
      described_class.host.should == "my_host"
    end

    it "local_host if @host is not specified" do
      described_class.host = nil
      described_class.host.should == "127.0.0.1"
    end
  end

  context ".ignore_exceptions?" do
    it "true if @ignore_exceptions is set to true" do
      described_class.ignore_exceptions = true
      described_class.should be_ignore_exceptions
    end

    it "false if @ignore_exceptions is set to false" do
      described_class.ignore_exceptions = false
      described_class.should_not be_ignore_exceptions
    end

    it "true if Rails.action_dispatch.show_exceptions is set to true for older Rails" do
      described_class.stub(legacy_rails?: true)
      described_class.ignore_exceptions = nil
      ::Rails.stub_chain(:configuration, :action_dispatch, :show_exceptions).and_return(true)

      described_class.should be_ignore_exceptions
    end

    it "true if Rails.action_dispatch.show_exceptions is set to true for Rails 3" do
      described_class.stub(legacy_rails?: false)
      described_class.ignore_exceptions = nil
      ::Rails.stub_chain(:application, :config, :action_dispatch, :show_exceptions).and_return(true)

      described_class.should be_ignore_exceptions
    end

    it "false if Rails.action_dispatch.show_exceptions is set to false for older Rails" do
      described_class.stub(legacy_rails?: true)
      described_class.ignore_exceptions = nil
      ::Rails.stub_chain(:configuration, :action_dispatch, :show_exceptions).and_return(false)

      described_class.should_not be_ignore_exceptions
    end

    it "true if Rails.action_dispatch.show_exceptions is set to false for Rails 3" do
      described_class.stub(legacy_rails?: false)
      described_class.ignore_exceptions = nil
      ::Rails.stub_chain(:application, :config, :action_dispatch, :show_exceptions).and_return(false)

      described_class.should_not be_ignore_exceptions
    end
  end

  context ".running?" do
    it "false if server thread is running" do
      fake_thread = double("thread", join: :still_running)
      described_class.instance_variable_set(:@server_thread, fake_thread)

      described_class.should_not be_running
    end

    it "false if server cannot be accessed" do
      fake_thread = double("thread", join: nil)
      described_class.instance_variable_set(:@server_thread, fake_thread)

      Net::HTTP.should_receive(:start).and_raise Errno::ECONNREFUSED
      described_class.should_not be_running
    end

    it "false if server response is not success" do
      fake_thread = double("thread", join: nil)
      described_class.instance_variable_set(:@server_thread, fake_thread)
      app = double("app")
      described_class.instance_variable_set(:@app, app)

      response = double(Net::HTTPSuccess, is_a?: false)
      Net::HTTP.should_receive(:start).and_return response
      described_class.should_not be_running
    end    

    it "true if server response is success" do
      fake_thread = double("thread", join: nil)
      described_class.instance_variable_set(:@server_thread, fake_thread)
      app = double("app")
      described_class.instance_variable_set(:@app, app)

      response = double(Net::HTTPSuccess, is_a?: true, body: app.object_id.to_s)
      Net::HTTP.should_receive(:start).and_return response
      described_class.should be_running
    end
  end
end
