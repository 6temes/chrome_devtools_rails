module ChromeDevtoolsJson
  class Engine < ::Rails::Engine
    isolate_namespace ChromeDevtoolsJson

    initializer "chrome_devtools_json.append_route" do |app|
      if Rails.env.development?
        app.routes.append do
          get "/.well-known/appspecific/com.chrome.devtools.json",
              to: "chrome_devtools_json/devtools#show",
              as: :chrome_devtools_json
        end
      end
    end
  end
end
