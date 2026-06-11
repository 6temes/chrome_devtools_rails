require "chrome_devtools_rails/version"
require "chrome_devtools_rails/engine"

module ChromeDevtoolsRails
  # Rails serves /.well-known/appspecific/com.chrome.devtools.json natively from
  # this version on, via the built-in Rails::DevToolsController, which makes this
  # gem unnecessary. See https://github.com/rails/rails/pull/56245.
  RAILS_NATIVE_SUPPORT_VERSION = Gem::Version.new("8.2")

  def self.deprecator
    @_deprecator ||= ActiveSupport::Deprecation.new("1.0", "chrome_devtools_rails")
  end

  def self.superseded_by_rails?
    Rails.gem_version >= RAILS_NATIVE_SUPPORT_VERSION
  end

  # Emitted at boot once Rails ships its own endpoint, so apps know they can drop
  # the gem. The route is still served, so nothing breaks on upgrade — this only
  # nudges migration to the native controller.
  def self.warn_if_superseded
    return unless superseded_by_rails?

    deprecator.warn(
      "chrome_devtools_rails is no longer needed on Rails #{Rails.version}: Rails serves " \
      "/.well-known/appspecific/com.chrome.devtools.json natively via Rails::DevToolsController. " \
      "Uncomment the devtools route in config/routes.rb and remove this gem from your Gemfile. " \
      "See https://github.com/rails/rails/pull/56245."
    )
  end
end
