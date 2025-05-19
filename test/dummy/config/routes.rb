Rails.application.routes.draw do
  mount ChromeDevtoolsJson::Engine => "/chrome_devtools_json"
end
