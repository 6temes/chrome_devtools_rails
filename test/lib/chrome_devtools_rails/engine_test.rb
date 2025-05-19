require "test_helper"

module ChromeDevtoolsRails
  class EngineTest < ActiveSupport::TestCase
    test "namespaced engine" do
      assert_kind_of Module, ChromeDevtoolsRails
      assert_kind_of Class, ChromeDevtoolsRails::Engine
      assert_equal "ChromeDevtoolsRails::Engine", ChromeDevtoolsRails::Engine.name
    end

    test "engine adds devtools route in development and test environments" do
      assert_includes ChromeDevtoolsRails::Engine.initializers.map(&:name),
                    "chrome_devtools_rails.append_route",
                    "Engine should have a route appending initializer"

      engine_initializes_in_environment = ->(env) do
        route_added = false
        test_app = Object.new
        routes = Object.new

        routes.define_singleton_method(:append) do |&block|
          route_added = true
        end

        test_app.define_singleton_method(:routes) { routes }

        Rails.stub :env, ActiveSupport::StringInquirer.new(env) do
          ChromeDevtoolsRails::Engine.initializers
            .find { _1.name == "chrome_devtools_rails.append_route" }
            .run(test_app)
        end

        route_added
      end

      assert engine_initializes_in_environment.call("development"),
             "Route should be added in development environment"

      assert engine_initializes_in_environment.call("test"),
             "Route should be added in test environment"

      refute engine_initializes_in_environment.call("production"),
             "Route should NOT be added in production environment"
    end
  end
end
