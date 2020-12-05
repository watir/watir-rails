require 'concurrent-ruby'

module Watir
  module Rails
    # @private
    class Middleware
      attr_accessor :error

      def initialize(app)
        @app = app
        @counter = Concurrent::AtomicFixnum.new(0)
      end

      def pending_requests?
        @counter.value > 0
      end

      def call(env)
        if env['PATH_INFO'] == '/__identify__'
          [200, {}, [@app.object_id.to_s]]
        else
          @counter.increment
          begin
            @app.call(env)
          rescue StandardError => e
            @error = e
            raise e
          ensure
            @counter.decrement
          end
        end
      end
    end
  end
end
