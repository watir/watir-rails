module Watir
  class Rails
    # @private
    class Middleware
      attr_accessor :error

      def initialize(app)
        @app = app
      end

      def call(env)
        if env["PATH_INFO"] == "/__identify__"
          [200, {}, [@app.object_id.to_s]]
        else
          begin
            @app.call(env)
          rescue => e
            @error = e
          end
        end
      end
    end

  end
end
