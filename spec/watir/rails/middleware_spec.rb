require 'spec_helper'

describe Watir::Rails::Middleware do
  let(:app) { double('app') }
  let(:middleware) { described_class.new app }

  context '#call' do
    it '/__identify__ returns app id' do
      expect(app).not_to receive(:call)
      expect(middleware.call('PATH_INFO' => '/__identify__')).to eq([200, {}, [app.object_id.to_s]])
    end

    it 'other requests are forwarded to the app' do
      env = {}
      expect(app).to receive(:call).with(env)
      middleware.call(env)
    end

    it 'errors are stored and re-raised' do
      error = RuntimeError.new
      allow(app).to receive(:call).and_raise error

      expect {
        middleware.call({})
      }.to raise_error(error)

      expect(middleware.error).to eq(error)
    end
  end
end
