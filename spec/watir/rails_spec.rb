require "spec_helper"

describe Watir::Rails do
  context "#boot" do
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
end
