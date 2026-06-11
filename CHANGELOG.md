# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Deprecation warning at boot when running on Rails 8.2 or newer, which serves
  `/.well-known/appspecific/com.chrome.devtools.json` natively via
  `Rails::DevToolsController` ([rails/rails#56245](https://github.com/rails/rails/pull/56245)).
  The route is still served, so upgrading does not break anything.

### Changed

- Raised the minimum Ruby version to 3.2.
- CI now runs the test suite across Ruby 3.2, 3.3, 3.4, and 4.0.

### Fixed

- Package the `LICENSE` file in the built gem (the gemspec referenced a
  non-existent `MIT-LICENSE`).

## [0.1.0] - 2023-05-19

### Added

- Initial release
- Automatic workspace mapping for Chrome DevTools
- Serves JSON file at `/.well-known/appspecific/com.chrome.devtools.json`
- UUID persistence in `tmp/chrome_devtools_uuid`
