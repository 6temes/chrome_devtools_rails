# ChromeDevtoolsJson

This gem provides a minimal Rails engine that automatically serves the Chrome DevTools workspace mapping file at:

```text
/.well-known/appspecific/com.chrome.devtools.json
```

When Chrome accesses this file from your local development server, it enables **automatic workspace folder mapping**, allowing you to edit and save source files (JS, CSS, etc.) directly from Chrome DevTools into your local Rails project.

This engine is **automatically mounted** and only active in **development mode**.

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
gem "chrome_devtools_json"

```

Then run:

```bash
bundle install
```

No route configuration is needed — the engine mounts itself automatically in development.

---

## ✅ Requirements

- Ruby ≥ 3.1
- Rails ≥ 8.0.2
- Google Chrome v89+ (with DevTools workspace support)

---

## 🤝 Contributing

Pull requests are welcome on GitHub at [https://github.com/6temes/chrome_devtools_json](https://github.com/6temes/chrome_devtools_json).

Ideas for improvement:

- Add support for regenerating the UUID
- Configurable root path
- Rake task or generator to inspect the current workspace config

---

## 📄 License

This gem is open source and released under the [MIT License](https://opensource.org/licenses/MIT).
