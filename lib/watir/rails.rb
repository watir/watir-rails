require 'uri'
require 'net/http'
require 'rack'
require 'watir-webdriver'
require File.expand_path("browser.rb", File.dirname(__FILE__))

module Watir
  class Rails
    # @private
    class Middleware
      attr_reader :error

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

    class << self
      private :new
      attr_reader :port, :middleware

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
        raise "Rack application timed out during boot"
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

      # Error rescued by middleware.
      #
      # @return [Exception or NilClass]
      def error
        @middleware.error
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
        @app ||= Rack::Builder.new do
          map "/" do
            if ::Rails.version.to_f >= 3.0
              run ::Rails.application
            else # Rails 2
              use ::Rails::Rack::Static
              run ActionController::Dispatcher.new
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

    end
  end
end
