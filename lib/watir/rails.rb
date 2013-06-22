require 'uri'
require 'net/http'
require 'rack'
require 'watir-webdriver'
require File.expand_path("browser.rb", File.dirname(__FILE__))
require File.expand_path("rails/middleware.rb", File.dirname(__FILE__))

module Watir
  class Rails
    class << self
      private :new
      attr_reader :port, :middleware
      attr_writer :ignore_exceptions

      # Start the Rails server for tests.
      # Will be called automatically by {Watir::Browser#initialize}.
      def boot
        unless running?
          @middleware = Middleware.new(app)
          @port = find_available_port

          @server_thread = Thread.new do
            run_default_server @middleware, @port
          end

          Timeout.timeout(60) { @server_thread.join(0.1) until running? }
        end
      rescue TimeoutError
        raise "Rails Rack application timed out during boot"
      end

      # Host for Rails app under test. When not set via {.host=} then
      # {.local_host} is used.
      #
      # @return [String] Host for Rails app under test.
      def host
        @host || local_host
      end

      # Set host for Rails app. Will be used by {Browser#goto} method.
      #
      # @param [String] host host to use when using {Browser#goto}.
      def host=(host)
        @host = host
      end

      # Local host for Rails app under test.
      #
      # @return [String] Local host with the value of "127.0.0.1".
      def local_host
        "127.0.0.1"
      end

      # Error rescued by the middleware.
      #
      # @return [Exception or NilClass]
      def error
        @middleware.error
      end

      # Set error rescued by the middleware.
      #
      # @param value
      def error=(value)
        @middleware.error = value
      end

      # Check if Rails exceptions should be ignored. Defaults to false.
      #
      # @return [Boolean] true if exceptions should be ignored, false otherwise.
      def ignore_exceptions?
        unless @ignore_exceptions
          show_exceptions = if legacy_rails?
                   ::Rails.configuration.action_dispatch.show_exceptions
                 else
                   ::Rails.application.config.action_dispatch.show_exceptions
                 end

          if show_exceptions
            warn '[WARN] "action_dispatch.show_exceptions" is set to "true", disabling watir-rails exception catcher.'
            @ignore_exceptions = true
          end
        end

        !!@ignore_exceptions
      end

      # Check if Rails app under test is running.
      #
      # @return [Boolean] true when Rails app under test is running, false otherwise.
      def running?
        return false if @server_thread && @server_thread.join(0)

        res = Net::HTTP.start(local_host, @port) { |http| http.get('/__identify__') }

        if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
          return res.body == @app.object_id.to_s
        end
      rescue Errno::ECONNREFUSED, Errno::EBADF
        return false
      end

      # Rails app under test.
      #
      # @return [Object] Rails Rack app.
      def app
        legacy = legacy_rails?
        @app ||= Rack::Builder.new do
          map "/" do
            if legacy
              use ::Rails::Rack::Static
              run ActionController::Dispatcher.new
            else
              run ::Rails.application
            end
          end
        end.to_app
      end

      private

      def find_available_port
        server = TCPServer.new(local_host, 0)
        server.addr[1]
      ensure
        server.close if server
      end

      def run_default_server(app, port)
        begin
          require 'rack/handler/thin'
          Thin::Logging.silent = true
          Rack::Handler::Thin.run(app, :Port => port)
        rescue LoadError
          require 'rack/handler/webrick'
          Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(nil, 0))
        end
      end

      def legacy_rails?
        ::Rails.version.to_f < 3.0
      end

    end
  end
end
