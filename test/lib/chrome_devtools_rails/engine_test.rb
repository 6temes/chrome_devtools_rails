require "test_helper"

module ChromeDevtoolsRails
  class EngineTest < ActiveSupport::TestCase
    test "engine is isolating namespace" do
      assert_kind_of Module, ChromeDevtoolsRails
      assert_kind_of Class,  ChromeDevtoolsRails::Engine
      assert_equal "ChromeDevtoolsRails::Engine", ChromeDevtoolsRails::Engine.name
    end

    test "routes only added in development" do
      app = Class.new(Rails::Application) { config.eager_load = false }.instance
      app.routes.draw { }
      initializer = ChromeDevtoolsRails::Engine
                    .initializers
                    .find { |i| i.name == "chrome_devtools_rails.append_route" }

      stub Rails, :env, ActiveSupport::StringInquirer.new("development") do
        initializer.run app
        paths = app.routes.routes.map { |r| r.path.spec.to_s }
        assert_includes paths, "/.well-known/appspecific/com.chrome.devtools.json"
      end

      app.routes.draw { }
      stub Rails, :env, ActiveSupport::StringInquirer.new("production") do
        initializer.run app
        paths = app.routes.routes.map { |r| r.path.spec.to_s }
        refute_includes paths, "/.well-known/appspecific/com.chrome.devtools.json"
      end
    end
  end
end
