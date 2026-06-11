# ChromeDevtoolsRails

This gem provides a minimal Rails engine that automatically serves the Chrome DevTools workspace mapping file at:

```text
/.well-known/appspecific/com.chrome.devtools.json
```

When Chrome accesses this file from your local development server, it enables **automatic workspace folder mapping**, allowing you to edit and save source files (JS, CSS, etc.) directly from Chrome DevTools into your local Rails project.

This engine is **automatically mounted** and only active in **development mode**.

---

## ⚠️ Rails 8.2+ ships this natively

As of **Rails 8.2**, Rails serves this endpoint itself through a built-in `Rails::DevToolsController` ([rails/rails#56245](https://github.com/rails/rails/pull/56245)). On Rails 8.2 or newer, uncomment the generated devtools route in `config/routes.rb` and you no longer need this gem.

This gem is still useful on **Rails 8.0 and 8.1**, which have no native support. When it detects Rails 8.2+, it keeps serving the endpoint but emits a deprecation warning so you know you can switch to the native controller and drop the dependency.

---

## 🚀 Usage

1. Visit your Rails app on `localhost`.
2. Open Chrome DevTools → **Sources** tab.
3. Chrome will auto-detect the `.well-known` file and prompt to map your local project.
4. Approve the mapping — changes made in DevTools will now be saved directly to disk.

---

## 🔧 Installation

Add this line to your application's `Gemfile`:

```ruby
gem "chrome_devtools_rails"
```

Then run:

```bash
bundle install
```

No route configuration is needed — the engine mounts itself automatically in development.

---

## ✅ Requirements

- Ruby ≥ 3.2
- Rails ≥ 8.0.2
- Google Chrome v89+ (with DevTools workspace support)

---

## 🤝 Contributing

Pull requests are welcome on GitHub at [https://github.com/6temes/chrome_devtools_rails](https://github.com/6temes/chrome_devtools_rails).

---

## 📄 License

This gem is open source and released under the [MIT License](https://opensource.org/licenses/MIT).
