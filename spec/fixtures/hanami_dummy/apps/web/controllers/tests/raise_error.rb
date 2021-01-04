module Web
  module Controllers
    module Tests
      class RaiseError
        include Web::Action

        def call(_params)
          raise 'watir-rails test message'
        end
      end
    end
  end
end
