require "spec_helper"

describe Watir::Rails do
  before { described_class.stub(:warn) }

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
    it "returns @host if specified" do
      described_class.host = "my_host"
      described_class.host.should == "my_host"
    end

    it "returns local_host if @host is not specified" do
      described_class.host = nil
      described_class.host.should == "127.0.0.1"
    end
  end

  context ".ignore_exceptions?" do
    it "returns true if @ignore_exceptions is set to true" do
      described_class.ignore_exceptions = true
      described_class.should be_ignore_exceptions
    end

    it "returns true if Rails.action_dispatch.show_exceptions is set to true for older Rails" do
      described_class.stub(legacy_rails?: true)
      described_class.ignore_exceptions = false
      ::Rails.stub_chain(:configuration, :action_dispatch, :show_exceptions).and_return(true)

      described_class.should be_ignore_exceptions
    end

    it "returns true if Rails.action_dispatch.show_exceptions is set to true for Rails 3" do
      described_class.stub(legacy_rails?: false)
      described_class.ignore_exceptions = false
      ::Rails.stub_chain(:application, :config, :action_dispatch, :show_exceptions).and_return(true)

      described_class.should be_ignore_exceptions
    end

    it "returns false if Rails.action_dispatch.show_exceptions is set to false for older Rails" do
      described_class.stub(legacy_rails?: true)
      described_class.ignore_exceptions = false
      ::Rails.stub_chain(:application, :config, :action_dispatch, :show_exceptions).and_return(false)

      described_class.should_not be_ignore_exceptions
    end

    it "returns true if Rails.action_dispatch.show_exceptions is set to false for Rails 3" do
      described_class.stub(legacy_rails?: false)
      described_class.ignore_exceptions = false
      ::Rails.stub_chain(:application, :config, :action_dispatch, :show_exceptions).and_return(false)

      described_class.should_not be_ignore_exceptions
    end
  end
end
