ChromeDevtoolsRails::Engine.routes.draw do
  get "/.well-known/appspecific/com.chrome.devtools.json", to: "devtools#show"
end