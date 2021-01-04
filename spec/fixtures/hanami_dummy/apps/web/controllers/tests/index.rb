module Web
  module Controllers
    module Tests
      class Index
        include Web::Action

        def call(_params)
          self.body = 'Hello world!'
        end
      end
    end
  end
end
