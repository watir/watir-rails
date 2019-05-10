module Watir
  class Hanami
    # @private
    class Middleware
      class PendingRequestsCounter
        attr_reader :value

        def initialize
          @value = 0
          @mutex = Mutex.new
        end

        def increment
          @mutex.synchronize { @value += 1 }
        end

        def decrement
          @mutex.synchronize { @value -= 1 }
        end
      end

      attr_accessor :error

      def initialize(app)
        @app = app
        @counter = PendingRequestsCounter.new
      end

      def pending_requests?
        @counter.value > 0
      end

      def call(env)
        if env["PATH_INFO"] == "/__identify__"
          [200, {}, [@app.object_id.to_s]]
        else
          @counter.increment
          begin
            @app.call(env)
          rescue => e
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
