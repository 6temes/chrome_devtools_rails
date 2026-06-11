# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Rails engine gem (`chrome_devtools_rails`) that serves the Chrome DevTools workspace mapping file at `/.well-known/appspecific/com.chrome.devtools.json`. When Chrome fetches this from a local dev server, it enables automatic workspace folder mapping, letting you edit and save source files from DevTools directly to disk.

Note: the gem and GitHub repo are named `chrome_devtools_rails`, but this working directory is `chrome_devtools_json`.

## Public gem — change with care

This is a **public repository** and a **published gem with at least one downstream gem depending on it**. Treat the following as a stable contract; changing any of it is a breaking change that requires a SemVer major/minor bump and a `CHANGELOG.md` entry:

- The gem name (`chrome_devtools_rails`) and the `ChromeDevtoolsRails::Engine` / `ChromeDevtoolsRails::DevtoolsController` constants.
- The named route `:chrome_devtools_json` and its URL helpers (dependents and host apps may reference them).
- The JSON response shape: `{ workspace: { root:, uuid: } }`.
- The auto-append-route-in-dev/test-only behavior (host apps rely on it doing nothing in production and requiring no manual `mount`).

Two things are **not** ours to change: the request path `/.well-known/appspecific/com.chrome.devtools.json` is fixed by Chrome, and `rake release` publishes publicly to RubyGems — run it only for an intentional release.

Because the repo is public, nothing committed here (including this file) should contain secrets or internal-only notes.

## Commands

```bash
bin/rails test                                    # run the full suite (Minitest)
bin/rails test test/unit/uuid_persistence_test.rb # single file
bin/rails test test/path/to/test.rb -n test_name  # single test by name
bin/rails test test/path/to/test.rb:LINE          # single test by line number
bin/rubocop                                        # lint (rubocop-rails-omakase / Omakase style)
bin/rubocop -a                                     # lint with safe autocorrect
rake build                                          # build the .gem into pkg/
rake release                                        # tag and push to RubyGems
```

CI (`.github/workflows/ci.yml`) runs `bin/rubocop -f github` and `bin/rails test` on Ruby 3.4.2. The test job installs `google-chrome-stable` to support potential system tests. Both lint and test must pass.

## Architecture

The entire engine is three source files plus a controller:

- `lib/chrome_devtools_rails/engine.rb` — the core mechanism. Instead of being `mount`ed by the host app, the engine uses an **initializer that appends a route directly to the host application's routes** (`app.routes.append`). This is why installation requires no route configuration. The route is added **only when `Rails.env.development?` or `Rails.env.test?`** — never in production. Any change to environment gating lives here.
- `app/controllers/chrome_devtools_rails/devtools_controller.rb` — renders `{ workspace: { root:, uuid: } }`. `root` is `Rails.root`; `uuid` is generated once via `SecureRandom.uuid` and **persisted to `tmp/chrome_devtools_uuid`**, then reused on every subsequent request so Chrome sees a stable workspace identity.
- `lib/chrome_devtools_rails/version.rb` / `lib/chrome_devtools_rails.rb` — version constant and require entrypoint.

### Testing setup

Tests run against a full dummy Rails app in `test/dummy/` (Rails 8, SQLite, Propshaft). `test/test_helper.rb` boots `test/dummy/config/environment` and wires fixtures. Stack: **Minitest** with **Mocha** for mocking and `minitest/spec` for the spec DSL.

Three test layers, each verifying a distinct concern:
- `test/lib/.../engine_test.rb` — confirms the route-appending initializer runs in development/test but **not** production (stubs `Rails.env` per environment).
- `test/controllers/.../devtools_controller_test.rb` — integration test of the JSON response and UUID persistence across requests.
- `test/unit/uuid_persistence_test.rb` — unit-tests the controller's private `uuid`/`persist_uuid` methods.

Tests that touch the UUID delete `tmp/chrome_devtools_uuid` in `setup` to start from a clean state — preserve this when adding UUID-related tests, since the file persists between runs.

## Requirements

Ruby ≥ 3.1, Rails ~> 8.0 (>= 8.0.2).
