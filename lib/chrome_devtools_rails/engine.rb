module ChromeDevtoolsRails
  class Engine < ::Rails::Engine
    isolate_namespace ChromeDevtoolsRails

    initializer "chrome_devtools_rails.append_route" do |app|
      if Rails.env.development? || Rails.env.test?
        app.routes.append do
          get "/.well-known/appspecific/com.chrome.devtools.json",
              to: "chrome_devtools_rails/devtools#show",
              as: :chrome_devtools_json
        end
      end
    end
  end
end
