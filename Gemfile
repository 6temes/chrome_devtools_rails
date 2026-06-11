source "https://rubygems.org"

# Specify your gem's dependencies in chrome_devtools_rails.gemspec.
gemspec

gem "puma"

gem "sqlite3"

gem "propshaft"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false
# parallel 2.x (a rubocop dependency) requires Ruby >= 3.3; cap it so the lint
# toolchain still installs on our supported Ruby 3.2.
gem "parallel", "< 2"

# Testing dependencies
gem "mocha", require: false
# minitest 6 extracted Object#stub / Minitest::Mock into its own gem.
gem "minitest-mock", require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
