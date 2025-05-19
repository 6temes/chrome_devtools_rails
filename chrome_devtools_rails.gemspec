require_relative "lib/chrome_devtools_rails/version"

Gem::Specification.new do |spec|
  spec.name        = "chrome_devtools_rails"
  spec.version     = ChromeDevtoolsRails::VERSION
  spec.authors     = [ "Daniel Lopez 👾" ]
  spec.email       = [ "daniel@6temes.cat" ]

  spec.summary     = "Serve com.chrome.devtools.json for Chrome automatic workspace setup"
  spec.description = "A Rails engine that automatically provides the /.well-known/appspecific/com.chrome.devtools.json endpoint for enabling Chrome DevTools automatic workspace mapping in development mode."

  spec.homepage    = "https://github.com/6temes/chrome_devtools_rails"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = "#{spec.homepage}/tree/main"
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/main/README.md"
  spec.metadata["changelog_uri"]     = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "rails", "~> 8.0", ">= 8.0.2"
end
