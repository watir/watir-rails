require 'spec_helper'

describe Watir::Rails do
  let(:webrick_logger) { StringIO.new }
  let(:wait_for_webrick?) { true }

  def run_with_rack_handler(app, localhost, port)
    Rack::Handler.get(:webrick).run(
      app,
      Host: localhost,
      Port: port,
      AccessLog: [],
      Logger: Logger.new(webrick_logger)
    )
  end

  # Wait for Webrick to start
  def wait_for_webrick
    return unless wait_for_webrick?

    loop do
      break unless server_thread.alive?
      break if webrick_logger.string.include?('WEBrick::HTTPServer#start')

      server_thread.run
    end
  end

  context '.boot' do
    let(:fake_server) { method(:run_with_rack_handler) }
    let(:localhost) { '127.0.0.13' }
    let(:random_port) do
      server = TCPServer.new(described_class.localhost, 0)
      port = server.local_address.ip_port
      server.close
      port
    end

    before do
      described_class.server = fake_server
      allow(Resolv).to receive(:getaddress).and_return(localhost)
    end

    shared_examples 'when specific port is not requested' do |requested_port:|
      context 'and server is not running' do
        context 'and free port can be found' do
          it 'starts the server on a random free port' do
            expect(described_class).not_to be_running

            expect(described_class).to receive(:find_available_port).and_return(random_port)
            expect(fake_server).to receive(:call).with(anything, localhost, random_port).once.and_call_original

            described_class.boot(port: requested_port)

            expect(described_class).to be_running
            expect(described_class.port).to eq(random_port)
          end
        end

        context 'and free port cannot be found' do
          before do
            allow(TCPServer).to receive(:new).with(described_class.localhost, 0)
                                             .and_raise(RuntimeError, 'cannot find port')
          end

          it 'fails with proper exception' do
            expect { described_class.boot }.to raise_error(RuntimeError, 'cannot find port')
          end
        end
      end

      context 'and server is running' do
        before do
          described_class.boot
          wait_for_webrick
        end

        it 'does not start server' do
          expect(described_class).to be_running
          expect(fake_server).not_to receive(:call)
          expect(described_class).not_to receive(:find_available_port)
        end
      end
    end

    context 'when `port: nil` is requested' do
      include_examples 'when specific port is not requested', requested_port: nil
    end

    context 'when `port: 0` is requested' do
      include_examples 'when specific port is not requested', requested_port: 0
    end

    context 'when specific port is requested' do
      context 'and server is not running' do
        context 'and port is available' do
          it 'starts the server on a provided port' do
            expect(described_class).not_to receive(:find_available_port)
            expect(fake_server).to receive(:call).with(anything, localhost, random_port).once.and_call_original

            described_class.boot(port: random_port)

            expect(described_class).to be_running
            expect(described_class.port).to eq(random_port)
          end
        end

        context 'and port is not available' do
          let!(:tcpserver) { TCPServer.new(described_class.localhost, random_port) }
          let(:expected_error) { Gem.win_platform? ? Errno::EACCES : Errno::EADDRINUSE }

          after { tcpserver.close }

          it 'fails with proper exception' do
            expect(described_class).not_to receive(:find_available_port)
            expect { described_class.boot(port: random_port) }.to raise_error(expected_error)
          end
        end
      end

      context 'and server is already running' do
        context 'on the same port' do
          before do
            described_class.boot(port: random_port)
            wait_for_webrick
          end

          it 'does not start server' do
            expect(described_class).to be_running
            expect(described_class.port).to eq(random_port)

            expect(fake_server).not_to receive(:call)
            expect(described_class).not_to receive(:find_available_port)

            described_class.boot(port: random_port)
          end
        end

        context 'on the different port' do
          before do
            described_class.boot
            wait_for_webrick
          end

          it 'starts server on the requested port' do
            expect(described_class).to be_running
            expect(described_class.port).not_to eq(random_port)

            expect(fake_server).to receive(:call).with(anything, localhost, random_port).and_call_original

            described_class.boot(port: random_port)

            expect(described_class).to be_running
            expect(described_class.port).to eq(random_port)
          end
        end
      end
    end

    context 'when server will not boot during timeout' do
      let(:fake_server) { ->(_app, _localhost, _port) { loop { Thread.stop } } }

      before { stub_const("#{described_class}::BOOT_TIMEOUT", 0.01) }

      it 'raises Timeout::Error' do
        expect(described_class).not_to be_running

        expect { described_class.boot }.to raise_error(Timeout::Error, 'Rails Rack application timed out during boot')
      end
    end

    context 'when application dies during boot' do
      let(:fake_server) { ->(_app, _localhost, _port) { Thread.current.kill } }

      it 'raises ThreadError' do
        expect(described_class).not_to be_running

        expect(fake_server).to receive(:call).and_call_original

        expect { described_class.boot }.to raise_error(ThreadError, 'Rails Rack application died on start')
      end
    end
  end

  context '.server' do
    let(:server) { method(:run_with_rack_handler) }
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

    it 'true if Rails.action_dispatch.show_exceptions is set to true', rails: true do
      described_class.ignore_exceptions = nil
      ::Rails.application.config.action_dispatch.show_exceptions = true

      expect(described_class).to receive(:warn)
        .with('[WARN] "action_dispatch.show_exceptions" is set to "true", disabling watir-rails exception catcher.')
      expect(described_class).to be_ignore_exceptions
    end

    it 'true if Rails.action_dispatch.show_exceptions is set to false', rails: true do
      described_class.ignore_exceptions = nil
      ::Rails.application.config.action_dispatch.show_exceptions = false

      expect(described_class).not_to be_ignore_exceptions
    end
  end

  context '.running?' do
    before { allow(described_class).to receive(:wait_for_server) }

    context 'when server thread has issues' do
      context 'when server thread is nil' do
        let(:fake_server_thread) { nil }

        it { expect(described_class).not_to be_running }
      end

      context 'when server thread is not alive' do
        before do
          described_class.server = ->(_app, _localhost, _port) { Thread.stop }
          described_class.boot
          server_thread.kill
          server_thread.join
        end

        it { expect(described_class).not_to be_running }
      end
    end

    context 'when server thread is running' do
      let(:fake_app) { 'I am fake app'.freeze }
      let(:fake_middleware) do
        local_server_response = server_response
        ->(_env) { local_server_response }
      end
      let(:fake_server) do
        ->(_app, localhost, port) { run_with_rack_handler(fake_middleware, localhost, port) }
      end

      before do
        described_class.server = fake_server
        allow(described_class).to receive(:app).and_return(fake_app)
        described_class.boot

        wait_for_webrick
      end

      context 'when refusing connections' do
        let(:fake_server) do
          lambda do |_app, _localhost, _port|
            loop { Thread.stop }
          end
        end
        let(:wait_for_webrick?) { false }

        it { expect(described_class).not_to be_running }
      end

      context 'when not Net::HTTPSuccess with correct response' do
        let(:server_response) { [500, {}, [fake_app.object_id.to_s]] }

        it { expect(described_class).not_to be_running }
      end

      context 'when Net::HTTPOK with wrong response' do
        let(:server_response) { [200, {}, ['wrong']] }

        it { expect(described_class).not_to be_running }
      end

      context 'when Net::HTTPSuccess and not Net::HTTPOK with correct response' do
        let(:fake_middleware) do
          local_fake_app = fake_app
          ->(_env) { [201, {}, [local_fake_app.object_id.to_s]] }
        end

        it { expect(described_class).not_to be_running }
      end

      context 'when Net::HTTPOK with correct response' do
        let(:fake_middleware) do
          local_fake_app = fake_app
          ->(_env) { [200, {}, [local_fake_app.object_id.to_s]] }
        end

        it { expect(described_class).to be_running }
      end
    end
  end

  context '.url' do
    subject(:url) { described_class.url(path) }

    context 'when path is an absolute url' do
      context 'when scheme is about:' do
        let(:path) { 'about:mozilla' }

        it { expect(url).to eq(path) }
      end

      context 'when scheme is data:' do
        let(:path) { 'data:foobar' }

        it { expect(url).to eq(path) }
      end

      context 'when scheme http:' do
        let(:path) { 'http://watir.com/blog/' }

        it { expect(url).to eq(path) }
      end

      context 'when https:' do
        let(:path) { 'https://github.com/watir/watir-rails/' }

        it { expect(url).to eq(path) }
      end
    end

    context 'when path is a relative url' do
      let(:path) { '/foo/bar?x=1&y[]=q&y[]=z#fragment' }
      let(:expected_url) { "http://#{described_class.host}:#{described_class.port}#{path}" }

      before { described_class.boot }

      it { expect(url).to eq(expected_url) }

      context 'and Watir::Rails.host includes username & password' do
        before { described_class.host = 'watir:rails@localhost' }

        it { expect(url).to eq(expected_url) }
      end
    end
  end

  context '.app' do
    subject(:app) { described_class.app }

    context 'when .app_path is not nil' do
      it { expect(app).to respond_to(:call) }
    end

    context 'when .app_path cannot be found' do
      let(:app_path) { '/does/not/exist/config.ru' }
      before { described_class.app_path = app_path }

      it { expect { app }.to raise_error(ArgumentError, "'#{app_path}' path to Rack app does not exist") }
    end

    context 'when .app_path is nil', rails: false do
      before { described_class.app_path = nil }

      it { expect { app }.to raise_error(ArgumentError, 'app_path is nil, cannot create Rake app') }
    end
  end
end
