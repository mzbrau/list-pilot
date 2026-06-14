# List Pilot

A smart shopping list app for Android built with Flutter. List Pilot helps you add items quickly, group them by category, and learn your in-store check-off order over time.

**Documentation:** [https://mzbrau.github.io/shop-flow/](https://mzbrau.github.io/shop-flow/)

**Download:** [GitHub Releases](https://github.com/mzbrau/shop-flow/releases/latest) (Google Play coming soon)

## Features

- Fast catalog autocomplete with 370+ built-in groceries
- Category grouping and multiple lists
- Smart ordering that learns your check-off route
- Light & dark mode, local-only storage (no cloud)

## Quick start

```bash
flutter pub get
dart run build_runner build
flutter run
flutter test
```

See the [developer setup guide](https://mzbrau.github.io/shop-flow/docs/developer-setup) for releases, signing, and documentation site development.

## Migrating from Shop Flow

List Pilot replaces Shop Flow with a new application ID. Existing Shop Flow installs cannot upgrade in place — export your custom catalog, uninstall Shop Flow, then install List Pilot. Details in the [upgrading guide](https://mzbrau.github.io/shop-flow/docs/upgrading).

## License

Apache 2.0 — see [LICENSE](LICENSE).
