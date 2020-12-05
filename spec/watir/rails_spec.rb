require 'spec_helper'

describe Watir::Rails do
  # We don't want memoization here, so no `let`
  def server_thread
    described_class.instance_variable_get(:@server_thread)
  end

  before do
    allow(described_class).to receive(:warn)
    described_class.ignore_exceptions = nil
    described_class.instance_eval { @middleware = @port = @server_thread = @localhost = @host = @app = nil }
  end

  after do
    if server_thread && server_thread.alive?
      server_thread.kill
      server_thread.join
    end
    described_class.instance_eval { @middleware = @port = @server_thread = @host = @app = nil }
  end

  context '.boot' do
    it 'starts the server unless already running' do
      server = ->(app, port) {}
      allow(described_class).to receive_messages(app: double('app'), find_available_port: 42)
      expect(described_class).to receive(:running?).twice.and_return(false, true)
      expect(described_class).to receive(:server).and_return(server)
      expect(server).to receive(:call).once

      described_class.boot
      wait_until_server_started
    end

    it 'does nothing if server is already running' do
      allow(described_class).to receive_messages(app: double('app'), find_available_port: 42)
      expect(described_class).to receive(:running?).once.and_return(true)
      expect(described_class).not_to receive(:server)

      described_class.boot
    end

    it "raises an error if Rails won't boot with timeout" do
      server = ->(app, port) {}
      allow(described_class).to receive_messages(app: double('app'),
                                                 find_available_port: 42, boot_timeout: 0.01)
      expect(described_class).to receive(:running?).at_least(:twice).and_return(false)
      expect(described_class).to receive(:server).and_return(server)
      expect(server).to receive(:call)

      expect {
        described_class.boot
      }.to raise_error(Timeout::Error)
    end

    def wait_until_server_started
      Timeout.timeout(10) { sleep 0.1 while server_thread.alive? }
    end
  end

  context '.server' do
    let(:server) do
      lambda do |app, localhost, port|
        Rack::Handler.get(:webrick).run(app, Host: localhost, Port: port, AccessLog: [], Logger: Logger.new(nil))
      end
    end
    let(:localhost) { '127.0.0.13' }

    before do
      described_class.server = server
      allow(Resolv).to receive(:getaddress).with('localhost').and_return(localhost)
    end

    it 'allows to customize server' do
      expect(server).to receive(:call).with(Watir::Rails::Middleware, localhost, Integer).once.and_call_original

      described_class.boot
    end
  end

  context '.host' do
    it 'returns @host if specified' do
      described_class.host = 'my_host'
      expect(described_class.host).to eq('my_host')
    end

    it 'returns localhost if @host is not specified' do
      expect(Resolv).to receive(:getaddress).with('localhost').and_return('127.0.0.13')
      expect(described_class.host).to eq('127.0.0.13')
    end

    it 'returns IPv6 with brackets if localhost is IPv6' do
      expect(Resolv).to receive(:getaddress).with('localhost').and_return('::1')
      expect(described_class.host).to eq('[::1]')
    end
  end

  context '.localhost' do
    it 'returns resolved localhost' do
      expect(Resolv).to receive(:getaddress).with('localhost').and_return('127.0.0.13')
      expect(described_class.localhost).to eq('127.0.0.13')
    end

    it 'returns IPv6 without brackets if localhost is IPv6' do
      expect(Resolv).to receive(:getaddress).with('localhost').and_return('::1')
      expect(described_class.localhost).to eq('::1')
    end
  end

  context '.ignore_exceptions?' do
    it 'true if @ignore_exceptions is set to true' do
      described_class.ignore_exceptions = true
      expect(described_class).to be_ignore_exceptions
    end

    it 'false if @ignore_exceptions is set to false' do
      described_class.ignore_exceptions = false
      expect(described_class).not_to be_ignore_exceptions
    end

    it 'true if Rails.action_dispatch.show_exceptions is set to true' do
      described_class.ignore_exceptions = nil
      allow(::Rails).to receive_message_chain(:application,
                                              :config, :action_dispatch, :show_exceptions).and_return(true)

      expect(described_class).to be_ignore_exceptions
    end

    it 'true if Rails.action_dispatch.show_exceptions is set to false' do
      described_class.ignore_exceptions = nil
      allow(::Rails).to receive_message_chain(:application,
                                              :config, :action_dispatch, :show_exceptions).and_return(false)

      expect(described_class).not_to be_ignore_exceptions
    end
  end

  context '.running?' do
    after { described_class.instance_variable_set(:@server_thread, nil) }

    it 'false if server thread is running' do
      fake_thread = instance_double(Thread, join: :still_running, alive?: false)
      described_class.instance_variable_set(:@server_thread, fake_thread)

      expect(described_class).not_to be_running
    end

    it 'false if server cannot be accessed' do
      fake_thread = instance_double(Thread, join: nil, alive?: false)
      described_class.instance_variable_set(:@server_thread, fake_thread)

      expect(Net::HTTP).to receive(:start).and_raise Errno::ECONNREFUSED
      expect(described_class).not_to be_running
    end

    it 'false if server response is not success' do
      fake_thread = instance_double(Thread, join: nil, alive?: false)
      described_class.instance_variable_set(:@server_thread, fake_thread)
      app = double('app')
      described_class.instance_variable_set(:@app, app)

      response = double(Net::HTTPSuccess, is_a?: false)
      expect(Net::HTTP).to receive(:start).and_return response
      expect(described_class).not_to be_running
    end

    it 'true if server response is success' do
      fake_thread = instance_double(Thread, join: nil, alive?: false)
      described_class.instance_variable_set(:@server_thread, fake_thread)
      app = double('app')
      described_class.instance_variable_set(:@app, app)

      response = double(Net::HTTPSuccess, is_a?: true, body: app.object_id.to_s)
      expect(Net::HTTP).to receive(:start).and_return response
      expect(described_class).to be_running
    end
  end
end
