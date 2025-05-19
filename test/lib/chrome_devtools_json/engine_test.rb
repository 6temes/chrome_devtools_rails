require "test_helper"

module ChromeDevtoolsJson
  class EngineTest < ActiveSupport::TestCase
    test "engine is isolating namespace" do
      assert_kind_of Module, ChromeDevtoolsJson
      assert_kind_of Class, ChromeDevtoolsJson::Engine
      assert_equal "ChromeDevtoolsJson::Engine", ChromeDevtoolsJson::Engine.name
    end

    test "routes are only added in development environment" do
      # Store original env
      original_env = Rails.env

      begin
        # Test development environment
        Rails.env = ActiveSupport::StringInquirer.new("development")
        app = Rails.application
        route_set = ActionDispatch::Routing::RouteSet.new

        Chrome_devtools_json::Engine.initializers.find { |i| i.name == "chrome_devtools_json.append_route" }.run(app)

        assert app.routes.routes.any? { |r| r.path.spec.to_s == "/.well-known/appspecific/com.chrome.devtools.json" }

        # Test production environment
        Rails.env = ActiveSupport::StringInquirer.new("production")
        app = Rails.application
        route_set = ActionDispatch::Routing::RouteSet.new

        # Check that routes are not added in production
        routes_count_before = app.routes.routes.size
        Chrome_devtools_json::Engine.initializers.find { |i| i.name == "chrome_devtools_json.append_route" }.run(app)
        routes_count_after = app.routes.routes.size

        assert_equal routes_count_before, routes_count_after
      ensure
        # Restore original env
        Rails.env = original_env
      end
    end
  end
end
