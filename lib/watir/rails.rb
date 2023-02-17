require "uri"
require "net/http"
require "rack"
require "watir"

require "rails"

require File.expand_path("rails/browser.rb", File.dirname(__FILE__))
require File.expand_path("rails/middleware.rb", File.dirname(__FILE__))

module Watir
  class Rails
    class << self
      private :new
      attr_reader :port, :middleware
      attr_writer :ignore_exceptions, :server

      # Start the Rails server for tests.
      # Will be called automatically by {Watir::Browser#initialize}.
      #
      # @param [Integer] port port for the Rails up to run on. If omitted use
      #   previously selected port or select random available port.
      def boot(port: nil)
        @port = port || @port || find_available_port

        unless running?
          @middleware = Middleware.new(app)

          @server_thread = Thread.new do
            server.call @middleware, @port
          end

          Timeout.timeout(boot_timeout) { @server_thread.join(0.1) until running? }
        end
      rescue Timeout::Error
        raise Timeout::Error, "Rails Rack application timed out during boot"
      end

      # Host for Rails app under test. Default is {.local_host}.
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

      # Returns true if there are pending requests to server.
      #
      # @return [Boolean]
      def pending_requests?
        @middleware.pending_requests?
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
        if @ignore_exceptions.nil?
          if ::Rails.application.config.action_dispatch.show_exceptions
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
      rescue Errno::ECONNREFUSED, Errno::EBADF, EOFError
        return false
      end

      # Rails app under test.
      #
      # @return [Object] Rails Rack app.
      def app
        @app ||= Rack::Builder.new do
          map "/" do
            run ::Rails.application
          end
        end.to_app
      end

      private

      def boot_timeout
        60
      end

      def find_available_port
        server = TCPServer.new(local_host, 0)
        server.addr[1]
      ensure
        server.close if server
      end

      def server
        @server ||= lambda do |app, port|
          begin
            require 'rack/handler/thin'
            Thin::Logging.silent = true
            return Rack::Handler::Thin.run(app, :Port => port)
          rescue LoadError
          end

          begin
            require 'rack/handler/puma'
            return Rack::Handler::Puma.run(app, :Port => port, :Silent => true)
          rescue LoadError
          end

          require 'rack/handler/webrick'
          Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(nil, 0))
        end
      end
    end
  end
end
