require 'resolv'

require 'rails'

require_relative 'rails/browser'
require_relative 'rails/middleware'

module Watir
  # Starts Rails application
  module Rails
    extend self

    attr_reader :port
    attr_writer :ignore_exceptions, :server, :host, :app_path

    delegate :error, :error=, :pending_requests?, to: :middleware

    # Start the Rails server for tests.
    # Will be called automatically by Watir::Rails::Browser#initialize.
    #
    # @param [Integer] port port for the Rails up to run on. If omitted random port will be picked.
    def boot(port: nil)
      return if self.port && (port.to_i.zero? || self.port == port) && running?

      self.port = port.to_i.zero? ? find_available_port : port

      start_server

      wait_for_server
    end

    # Host for Rails app under test. Default is {.localhost}.
    #
    # @return [String] Host for Rails app under test.
    def host
      @host || URI::HTTP.build(host: localhost).host
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
      if ignore_exceptions.nil?
        if ::Rails.application.config.action_dispatch.show_exceptions
          warn '[WARN] "action_dispatch.show_exceptions" is set to "true", disabling watir-rails exception catcher.'
          self.ignore_exceptions = true
        end
      end

      !!ignore_exceptions
    end

    # Check if Rails app under test is running.
    #
    # @return [Boolean] true when Rails app under test is running, false otherwise.
    def running?
      return false if server_thread.nil?
      return false unless server_thread.alive?

      res = Net::HTTP.start(localhost, port, open_timeout: 1, read_timeout: 1) do |http|
        http.get(Middleware::IDENTIFY_PATH)
      end

      res.is_a?(Net::HTTPOK) && res.body == app.object_id.to_s
    rescue Errno::ECONNREFUSED, Errno::EBADF, EOFError, Net::ReadTimeout, Net::OpenTimeout
      false
    end

    def middleware
      @middleware ||= Rack::Builder.app do
        use Middleware
        run Watir::Rails.app
      end
    end

    # Rails app under test.
    #
    # @return [Object] Rails Rack app.
    def app
      @app ||= Rack::Builder.parse_file(app_path).first
    end

    # Converts rails path into accessible Watir::Rails URL
    # does nothing if path is an absolute URL already
    #
    # @example Go to the regular url:
    #   browser.goto "http://google.com"
    #
    # @example Go to the controller path:
    #   browser.goto home_path
    #
    # @param [String] path path to be converted to Watir::Rails URL
    def url(path)
      uri = URI.parse(path)
      return path if uri.absolute?

      userinfo, _, host = self.host.rpartition('@') # rubocop:disable Style/RedundantSelf

      URI::HTTP.build(host: host, port: port, userinfo: userinfo).merge(uri).to_s
    end

    private

    attr_writer :port
    attr_reader :ignore_exceptions, :server_thread

    def app_path
      @app_path ||= ::Rails.root.join('config.ru').to_s
    end

    def boot_timeout
      60
    end

    def start_server
      @server_thread = Thread.new do
        Thread.current.abort_on_exception = true
        server.call(middleware, localhost, port)
      end
    end

    def wait_for_server
      Timeout.timeout(boot_timeout) do
        loop do
          break if running?

          server_thread.run
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
