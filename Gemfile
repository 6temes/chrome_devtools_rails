source "https://rubygems.org"

# Specify your gem's dependencies in chrome_devtools_rails.gemspec.
gemspec

gem "mocha"
# parallel 2.x (a rubocop dependency) requires Ruby >= 3.3; cap it so the lint
# toolchain still installs on our supported Ruby 3.2.
gem "parallel", "< 2"
gem "propshaft"
gem "rubocop-rails-omakase", require: false
gem "sqlite3"
