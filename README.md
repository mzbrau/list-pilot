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
