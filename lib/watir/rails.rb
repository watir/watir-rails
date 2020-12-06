require 'resolv'
require 'watir'

require 'rails'

require_relative 'rails/browser'
require_relative 'rails/middleware'

module Watir
  # Starts Rails application
  module Rails
    extend self

    attr_reader :port, :middleware
    attr_writer :ignore_exceptions, :server

    delegate :error, :error=, :pending_requests?, to: :middleware

    # Start the Rails server for tests.
    # Will be called automatically by Watir::Rails::Browser#initialize.
    #
    # @param [Integer] port port for the Rails up to run on. If omitted random port will be picked.
    def boot(port: nil)
      return if @port && (port.to_i.zero? || @port == port) && running?

      @port = port.to_i.zero? ? find_available_port : port

      @middleware = Middleware.new(app)

      start_server

      wait_for_server
    end

    # Host for Rails app under test. Default is {.localhost}.
    #
    # @return [String] Host for Rails app under test.
    def host
      @host || URI::HTTP.build(host: localhost).host
    end

    # Set host for Rails app. Will be used by {Browser#goto} method.
    #
    # @param [String] host host to use when using {Browser#goto}.
    def host=(host)
      @host = host
    end

    # Local host for Rails app under test.
    #
    # @return [String] Resolved `localhost` address
    def localhost
      @localhost ||= Resolv.getaddress('localhost')
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
      return false if @server_thread.nil?
      return false unless @server_thread.alive?

      res = Net::HTTP.start(localhost, @port, open_timeout: 1, read_timeout: 1) do |http|
        http.get('/__identify__')
      end

      res.is_a?(Net::HTTPOK) && res.body == app.object_id.to_s
    rescue Errno::ECONNREFUSED, Errno::EBADF, EOFError, Net::ReadTimeout, Net::OpenTimeout
      false
    end

    # Rails app under test.
    #
    # @return [Object] Rails Rack app.
    def app
      @app ||= ::Rails.application
    end

    private

    def boot_timeout
      60
    end

    def start_server
      @server_thread = Thread.new do
        Thread.current.abort_on_exception = true
        server.call(@middleware, localhost, @port)
      end
    end

    def wait_for_server
      Timeout.timeout(boot_timeout) do
        loop do
          break if running?

          @server_thread.run
        end
      end
    rescue Timeout::Error
      raise Timeout::Error, 'Rails Rack application timed out during boot'
    rescue ThreadError
      raise ThreadError, 'Rails Rack application died on start'
    end

    def find_available_port
      server = TCPServer.new(localhost, 0)
      server.local_address.ip_port
    ensure
      server.close if server
    end

    def server
      @server ||= lambda do |app, localhost, port|
        if Rack::Handler.default.name == 'Rack::Handler::Puma'
          # HACK: https://github.com/puma/puma/pull/2521
          localhost = URI::HTTP.build(host: localhost).host
        end

        Rack::Handler.default.run(
          app,
          Host: localhost,
          Port: port,
          Silent: true,
          AccessLog: [],
          Logger: Logger.new(nil)
        )
      end
    end
  end
end
