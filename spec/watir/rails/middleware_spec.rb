require 'spec_helper'

describe Watir::Rails::Middleware do
  let(:middleware) { described_class.new app }

  context '#call' do
    let(:app) { ->(_env) {} }

    it '/__identify__ returns app id' do
      expect(app).not_to receive(:call)
      expect(middleware.call('PATH_INFO' => '/__identify__')).to eq([200, {}, [app.object_id.to_s]])
    end

    it 'other requests are forwarded to the app' do
      env = {}
      expect(app).to receive(:call).with(env)
      middleware.call(env)
    end

    context 'when app is raising an error' do
      let(:app) { ->(env) { raise env[:error] } }
      let(:error) { RuntimeError.new('oops') }

      it 'errors are stored and re-raised' do
        error = RuntimeError.new

        expect { middleware.call(error: error) }.to raise_error(error)

        expect(middleware.error).to be(error)
      end
    end
  end

  context '#pending_requests?' do
    let(:app) { ->(_env) { sleep } }
    let(:sleep_thread) { Thread.new { middleware.call({}) } }

    it 'works' do
      expect(middleware.pending_requests?).to be(false)

      sleep_thread.join(0.1)
      expect(middleware.pending_requests?).to be(true)

      sleep_thread.kill
      sleep_thread.join
      expect(middleware.pending_requests?).to be(false)
    end
  end
end
