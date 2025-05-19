ChromeDevtoolsRails::Engine.routes.draw do
  get "/.well-known/appspecific/com.chrome.devtools.json", to: "devtools#show", as: :chrome_devtools_json
end
