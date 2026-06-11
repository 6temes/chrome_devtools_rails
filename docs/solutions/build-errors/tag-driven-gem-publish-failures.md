---
title: Tag-driven gem publish fails (OIDC trusted-publishing + frozen lockfile)
date: 2026-06-11
category: build-errors
module: Gem release pipeline (GitHub Actions)
problem_type: build_error
component: tooling
symptoms:
  - "No trusted publisher configured for this workflow found on rubygems.org for audience rubygems.org"
  - "The gemspecs for path gems changed, but the lockfile can't be updated because frozen mode is set (Bundler::ProductionError)"
  - "gem-push workflow exits 1 at the publish step; the GitHub release is created but no version reaches RubyGems"
root_cause: config_error
resolution_type: config_change
severity: medium
related_components: [development_workflow]
tags: [gem-release, rubygems, trusted-publishing, oidc, github-actions, bundler-frozen, gem-push, release-drafter]
---

# Tag-driven gem publish fails (OIDC trusted-publishing + frozen lockfile)

## Problem

A tag-driven RubyGems publish pipeline (release-drafter → push a `vX.Y.Z` tag → `gem-push.yml` publishes via OIDC trusted publishing, with an ENV-injected gem version) failed to publish in two distinct ways before succeeding. Both failures surface only at publish time, because the publish workflow is tags-only and is never exercised by PR/CI.

## Symptoms

- `No trusted publisher configured for this workflow found on https://rubygems.org for audience rubygems.org` — the OIDC credential step fails.
- `The gemspecs for path gems changed, but the lockfile can't be updated because frozen mode is set (Bundler::ProductionError)` — fails during the build step of the publish job.
- The `vX.Y.Z` GitHub release and tag exist, but no version appears on RubyGems.

## What Didn't Work

- **First attempt — no trusted publisher yet.** OIDC auth failed outright; trusted publishing had not been configured on RubyGems for the gem. Configuring it was necessary but not sufficient (see next).
- **Setting the RubyGems "Environment" field to `release`.** The RubyGems guide *suggests* `release`, but the workflow declared no `environment:`. The OIDC token therefore carried no environment claim, so it didn't match the configured publisher — same `No trusted publisher configured` error. Fix: leave Environment **blank** so it matches the workflow.
- **`@dependabot`-style re-run of the failed workflow.** After fixing auth, the build step failed on the frozen lockfile. Re-running the same run didn't help — a tag-triggered run uses the workflow **as it existed at the tagged commit**, so the fix has to land on `main` and the tag be re-cut.
- **`rubygems/release-gem` + `bundler-cache: true`.** The action runs `bundle exec rake build`; `bundler-cache: true` puts bundler in frozen/deployment mode. The ENV-injected release version (`0.2.0`) differs from the committed `Gemfile.lock`, which pins the path gem at its dev default (`0.0.0.dev`) → `Bundler::ProductionError`.

## Solution

Two independent fixes — one on RubyGems, one in the workflow.

**1. Trusted publisher must mirror the workflow's OIDC claims.** On `rubygems.org/gems/<gem>/trusted_publishers`, set repository owner/name and **Workflow filename = `gem-push.yml`** (just the filename), and leave **Environment blank** unless the workflow declares `environment:`.

**2. Build/push without bundler**, so the dev-pinned lockfile can't trip frozen mode. Drop `bundler-cache: true` and replace `rubygems/release-gem` with explicit `gem build`/`gem push`:

```yaml
      - name: Set up Ruby
        uses: ruby/setup-ruby@<sha> # v1
        with:
          ruby-version: "4.0"
          # NOTE: no bundler-cache — gem build/push don't need the bundle

      - name: Extract version from tag
        id: version
        run: echo "version=${GITHUB_REF_NAME#v}" >> "$GITHUB_OUTPUT"

      - name: Configure RubyGems credentials
        uses: rubygems/configure-rubygems-credentials@<sha> # v1.0.0

      - name: Build and push gem
        env:
          MY_GEM_VERSION: ${{ steps.version.outputs.version }}
        run: |
          gem build my_gem.gemspec
          gem push "my_gem-${MY_GEM_VERSION}.gem"
```

Because the tag already pointed at the pre-fix commit, the release/tag had to be deleted and re-created at the fixed commit to re-trigger publishing.

## Why This Works

- **OIDC matching is exact.** Trusted publishing matches the token's claims (repo, workflow filename, ref, and environment) against the configured publisher. An Environment value with no corresponding `environment:` in the workflow means the token has no environment claim to match — blank-to-blank matches, `release`-to-nothing does not.
- **`gem build` bypasses bundler.** The pattern `VERSION = ENV.fetch("MY_GEM_VERSION", "0.0.0.dev")` means the committed `Gemfile.lock` records the path gem at `0.0.0.dev`, while at release the gemspec evaluates to the real tag version. `bundle` in frozen/deployment mode refuses to reconcile that lockfile↔gemspec mismatch. `gem build` reads the gemspec alone and never consults the lockfile, so frozen mode is irrelevant.

## Prevention

- For tag-driven publishing with an **ENV-injected version + committed `Gemfile.lock`**, build with `gem build`/`gem push` — not `bundle exec rake build` or `rubygems/release-gem`, which run frozen in CI.
- When configuring trusted publishing, **read the workflow first**: the Environment field must be blank if there's no `environment:`, or the exact name if there is. A mismatch fails closed with "No trusted publisher configured."
- Remember tag-triggered workflows run the workflow **at the tagged commit** — fix on `main`, then re-cut the tag; don't just re-run.
- The publish path isn't covered by PR CI (gem-push is tags-only), so validate it on the **first real release** and treat that release as the test.

## Related Issues

- `chrome_devtools_rails` PR #8 (fix); first successful publish was `chrome_devtools_rails 0.2.0`.
- Ported to the sibling gems sharing this release convention: `rails-informant` #73, `rails_mcp_code_search` #36, `opentelemetry-instrumentation-sqlite3` #29.
