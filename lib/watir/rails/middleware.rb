require 'concurrent-ruby'

module Watir
  module Rails
    # @private
    class Middleware
      IDENTIFY_PATH = '/__identify__'.freeze

      attr_accessor :error

      def initialize(app)
        @app = app
        @counter = Concurrent::AtomicFixnum.new(0)
      end

      def pending_requests?
        @counter.value > 0
      end

      def call(env)
        return [200, {}, [@app.object_id.to_s]] if env['PATH_INFO'] == IDENTIFY_PATH

        @counter.increment

        begin
          @app.call(env)
        rescue StandardError => e
          @error = e
          raise
        ensure
          @counter.decrement
        end
      end
    end
  end
end
