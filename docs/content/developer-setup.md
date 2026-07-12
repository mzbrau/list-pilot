---
sidebar_position: 3
---

# Developer setup

List Pilot is a Flutter app. This guide covers building and running from source.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.5+)
- [Node.js 20+](https://nodejs.org/) (for documentation site only)

## Setup

```bash
git clone https://github.com/mzbrau/list-pilot.git
cd list-pilot
flutter pub get
dart run build_runner build
```

## Run

```bash
flutter run
```

## Test

```bash
flutter test
```

## Continuous integration

Pushes to `main` and pull requests run [`.github/workflows/ci.yml`](https://github.com/mzbrau/list-pilot/blob/main/.github/workflows/ci.yml), which:

- Runs `flutter analyze` (build diagnostics)
- Runs `flutter test --coverage` with JUnit XML output for [Actions Insights](https://www.ghactionsinsights.com/)
- Publishes test reports as PR comments, workflow summaries, GitHub Checks, and an HTML artifact

Tests that depend on local-only `Reference/` data are skipped in CI when that folder is absent.

### Actions Insights history dashboard (one-time setup)

The CI workflow can push trend data to a dedicated history repository. Complete these steps once before history appears on the dashboard:

1. **Initialize the history repository** (creates `mzbrau/actions-insights-history`):

   ```bash
   curl -fsSL https://raw.githubusercontent.com/mzbrau/actions-insights/main/scripts/init-history-repo.sh | bash -s -- init
   ```

   Or with the GitHub CLI extension:

   ```bash
   gh extension install mzbrau/gh-actions-insights
   gh actions-insights init
   ```

2. **Create a PAT** with `contents: write` scoped to `mzbrau/actions-insights-history` only.

3. **Add the secret** to this repository (`mzbrau/list-pilot`):
   - Name: `ACTIONS_INSIGHTS_HISTORY_TOKEN`
   - Value: the PAT from step 2

4. **Register this repo** in the history repository config (covered by the init script/docs).

History push is skipped on fork PRs (secrets are unavailable). After setup, push to `main` and confirm the Test Coverage and Build Insights tabs on the history dashboard.

## Project structure

```
lib/
  core/           # Theme, constants, Riverpod providers
  data/           # Drift database, repositories, seed loader
  features/       # Screens and widgets
  router/         # go_router configuration
assets/
  seed_catalog.json
docs/             # Docusaurus documentation site
```

## Releasing

Releases are driven by git tags in the form `vX.Y.Z`:

```bash
./tool/set_version.sh v1.0.0
git add pubspec.yaml
git commit -m "Release v1.0.0"
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

Pushing a tag triggers the GitHub Action that builds an Android APK (`list-pilot-X.Y.Z.apk`) and attaches it to a GitHub Release.

### Local release builds

Create `android/key.properties` (gitignored):

```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=upload
storeFile=app/upload-keystore.jks
```

Copy your keystore to `android/app/upload-keystore.jks`.

## Documentation site

The docs site lives in `docs/` and deploys to GitHub Pages on pushes to `main`.

```bash
cd docs
npm ci
npm start    # local dev server
npm run build
```

Enable **GitHub Pages → Source: GitHub Actions** in repository settings for deployment.

Site URL: [https://mzbrau.github.io/list-pilot/](https://mzbrau.github.io/list-pilot/)

## License

Apache 2.0 — see [LICENSE](https://github.com/mzbrau/list-pilot/blob/main/LICENSE).
