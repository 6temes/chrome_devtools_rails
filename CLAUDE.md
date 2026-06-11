# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Rails engine gem (`chrome_devtools_rails`) that serves the Chrome DevTools workspace mapping file at `/.well-known/appspecific/com.chrome.devtools.json`. When Chrome fetches this from a local dev server, it enables automatic workspace folder mapping, letting you edit and save source files from DevTools directly to disk.

## Lifecycle — superseded by Rails 8.2

Rails 8.2 serves this endpoint natively via a built-in `Rails::DevToolsController` ([rails/rails#56245](https://github.com/rails/rails/pull/56245)), so this gem's purpose is bounded — it's the working solution only for Rails 8.0/8.1. On Rails 8.2+ the gem still serves the route (no breakage on upgrade) but emits a deprecation at boot. The version gate lives in `lib/chrome_devtools_rails.rb` as `RAILS_NATIVE_SUPPORT_VERSION` (`8.2`) + `warn_if_superseded`; the engine calls it in development only. Bump `RAILS_NATIVE_SUPPORT_VERSION` only if Rails changes which version first ships native support.

## Public gem — change with care

This repository is **public** and produces the published gem **`chrome_devtools_rails`** (RubyGems: https://rubygems.org/gems/chrome_devtools_rails). Real Rails apps depend on it via their `Gemfile`, so treat the following as a stable contract; changing any of it is a breaking change that requires a version bump (via the release tag) and a release note:

- The gem name (`chrome_devtools_rails`) and the `ChromeDevtoolsRails::Engine` / `ChromeDevtoolsRails::DevtoolsController` constants.
- The named route `:chrome_devtools_json` and its URL helpers (dependents and host apps may reference them).
- The JSON response shape: `{ workspace: { root:, uuid: } }`.
- The auto-append-route-in-dev/test-only behavior (host apps rely on it doing nothing in production and requiring no manual `mount`).

One thing is **not** ours to change: the request path `/.well-known/appspecific/com.chrome.devtools.json` is fixed by Chrome. Releasing publishes publicly to RubyGems (see Releasing) — tag only for an intentional release.

Because the repo is public, nothing committed here (including this file) should contain secrets or internal-only notes.

## Commands

```bash
bundle exec rake test                                   # run the full suite (Minitest)
bin/test test/unit/uuid_persistence_test.rb             # single file
ruby -Itest test/unit/uuid_persistence_test.rb -n NAME  # single test by name
bundle exec rubocop                                     # lint (rubocop-rails-omakase / Omakase style)
bundle exec rubocop -a                                  # lint with safe autocorrect
bundle exec rake build                                  # build the .gem into pkg/
```

CI runs four workflows, with all GitHub Action refs SHA-pinned: `ci.yml` (`bundle exec rubocop` on Ruby 4.0 + `bundle exec rake test` across a Ruby 3.2–4.0 matrix), `codeql.yml` (weekly + PR security scanning), `release-drafter.yml`, and `gem-push.yml`. The dev/lint toolchain pins `parallel < 2` because rubocop's `parallel 2.x` requires Ruby ≥ 3.3 while we still support 3.2.

## Releasing

Tag-driven — no manual `rake release`, no API key:

- `release-drafter` keeps a draft GitHub Release updated from merged PR titles on every push to `main` (default bump is patch; label PRs to bump minor/major).
- Pushing a `vX.Y.Z` tag triggers `gem-push.yml`, which builds with `CHROME_DEVTOOLS_RAILS_VERSION` set from the tag (`lib/chrome_devtools_rails/version.rb` reads it; default `0.0.0.dev`) and publishes to RubyGems via **OIDC trusted publishing**.

Requires the GitHub repo to be registered as a trusted publisher for the gem on rubygems.org.

## Architecture

The entire engine is three source files plus a controller:

- `lib/chrome_devtools_rails/engine.rb` — the core mechanism. Instead of being `mount`ed by the host app, the engine uses an **initializer that appends a route directly to the host application's routes** (`app.routes.append`). This is why installation requires no route configuration. The route is added **only when `Rails.env.development?` or `Rails.env.test?`** — never in production. Any change to environment gating lives here.
- `app/controllers/chrome_devtools_rails/devtools_controller.rb` — renders `{ workspace: { root:, uuid: } }`. `root` is `Rails.root`; `uuid` is generated once via `SecureRandom.uuid` and **persisted to `tmp/chrome_devtools_uuid`**, then reused on every subsequent request so Chrome sees a stable workspace identity.
- `lib/chrome_devtools_rails.rb` — require entrypoint, plus the Rails 8.2 deprecation gate (`RAILS_NATIVE_SUPPORT_VERSION`, `superseded_by_rails?`, `warn_if_superseded`, and the gem's `deprecator`).
- `lib/chrome_devtools_rails/version.rb` — `VERSION`, read from the `CHROME_DEVTOOLS_RAILS_VERSION` env at build time (default `0.0.0.dev`); the release tag supplies the real version.

### Testing setup

Run with `bundle exec rake test` (a `Rake::TestTask` over `test/**/*_test.rb`). Tests run against a full dummy Rails app in `test/dummy/` (Rails 8, SQLite, Propshaft); `test/test_helper.rb` boots `test/dummy/config/environment`. Stack: **Minitest** with **Mocha** for stubbing (`stubs`/`returns` — minitest 6 removed `Object#stub`).

Three test layers, each verifying a distinct concern:
- `test/lib/.../engine_test.rb` — confirms the route-appending initializer runs in development/test but **not** production (stubs `Rails.env` per environment, via Mocha).
- `test/lib/.../deprecation_test.rb` — stubs `Rails.gem_version` to assert the deprecation fires on 8.2+ and stays quiet below it.
- `test/controllers/.../devtools_controller_test.rb` — integration test of the JSON response and UUID persistence across requests.
- `test/unit/uuid_persistence_test.rb` — unit-tests the controller's private `uuid`/`persist_uuid` methods.

Tests that touch the UUID delete `tmp/chrome_devtools_uuid` in `setup` to start from a clean state — preserve this when adding UUID-related tests, since the file persists between runs.

## Requirements

Ruby ≥ 3.2, Rails ~> 8.0 (>= 8.0.2).
