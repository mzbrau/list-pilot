# Shop Flow

A smart shopping list app for iOS and Android built with Flutter. Shop Flow helps you add items quickly, group them by category, and learn your in-store check-off order over time so you can work through the list top to bottom.

## Features

- **Fast item entry** — autocomplete from a built-in catalog of 370+ groceries, plus custom items you teach the app
- **Category grouping** — items organized under headers like Dairy, Fruit & Veg, Meat, Frozen, and more
- **Multiple lists** — separate lists for different stores (supermarket, hardware store, etc.)
- **Smart ordering** — learns your check-off sequence per list and reorders active items over time
- **Completed section** — checked items move to a muted section at the bottom; clear all when done
- **Item details** — edit name, quantity (count or weight), category; remove custom items from memory
- **Light & dark mode** — follows system theme with manual override
- **Local only** — all data stored on device via SQLite (no cloud sync)

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.5+)

### Setup

```bash
flutter pub get
dart run build_runner build
```

### Run

```bash
flutter run
```

### Test

```bash
flutter test
```

## Releasing

Releases are driven by git tags in the form `vX.Y.Z` (e.g. `v1.0.0`). The tag sets the app version in `pubspec.yaml` and triggers a GitHub Action that builds an Android APK and attaches it to a GitHub Release.

### Create a release

```bash
./tool/set_version.sh v1.0.0
git add pubspec.yaml
git commit -m "Release v1.0.0"
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

The `set_version.sh` step is optional before tagging — CI applies the version from the tag when building — but committing the updated `pubspec.yaml` keeps the repo in sync.

Version numbers use semver (`X.Y.Z`). The Android build number is derived automatically as `major*10000 + minor*100 + patch` (e.g. `v1.2.3` → build `10203`).

### Install the APK on Android

1. Open the [GitHub Releases](https://github.com/mzbrau/shop-flow/releases) page for this repo.
2. Download the `shop-flow-X.Y.Z.apk` file from the latest release.
3. On your phone, allow installation from unknown sources for your browser or file manager.
4. Open the downloaded APK and install.

Release APKs are debug-signed for sideloading only — they are not suitable for Google Play.

## Project structure

```
lib/
  core/           # Theme, constants, Riverpod providers
  data/           # Drift database, repositories, seed loader
  features/       # Screens and widgets (lists, shopping list, item detail, learning)
  router/         # go_router configuration
assets/
  seed_catalog.json
```

## How smart ordering works

Each time you check off an item, Shop Flow records the event for that list. Over multiple shopping trips it computes median category and item ranks (ignoring bulk checkout taps). After three or more trips, the list reorders active items to match your usual route through the store. Use **Reset learned order** in the list menu to start fresh.

## License

Apache 2.0 — see [LICENSE](LICENSE).
