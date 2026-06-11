require_relative "lib/chrome_devtools_rails/version"

Gem::Specification.new do |spec|
  spec.name = "chrome_devtools_rails"
  spec.version = ChromeDevtoolsRails::VERSION
  spec.authors = [ "Daniel López Prat" ]
  spec.email = [ "daniel@6temes.cat" ]
  spec.homepage = "https://github.com/6temes/chrome_devtools_rails"
  spec.summary = "Serve com.chrome.devtools.json for Chrome automatic workspace setup"
  spec.description = "A Rails engine that automatically provides the /.well-known/appspecific/com.chrome.devtools.json endpoint for enabling Chrome DevTools automatic workspace mapping in development mode."
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/6temes/chrome_devtools_rails/issues",
    "changelog_uri" => "https://github.com/6temes/chrome_devtools_rails/releases",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/6temes/chrome_devtools_rails"
  }

  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir.chdir(__dir__) do
    Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 8.0", ">= 8.0.2"
end
