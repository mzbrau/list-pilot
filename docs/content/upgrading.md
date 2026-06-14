---
sidebar_position: 1
---

# Upgrading

List Pilot supports in-place upgrades on Android when the new APK is signed with the same certificate and uses the same application ID (`com.listpilot.list_pilot`).

## Normal upgrades

Once you have List Pilot installed from a GitHub Release:

1. Download the latest `list-pilot-X.Y.Z.apk` from [Releases](https://github.com/mzbrau/list-pilot/releases).
2. Open the APK on your phone.
3. Install over the existing app — **your data is preserved** (lists, custom catalog, learned order).

:::tip No uninstall needed
In-place upgrades keep your SQLite database intact. You should never need to uninstall between normal releases.
:::

## Migrating from debug-signed releases

Early GitHub releases may have been signed with ephemeral CI debug keys. If an upgrade fails with "App not installed":

1. Export your custom catalog (Settings → Export custom catalog).
2. Uninstall the old build.
3. Install the first release built with the stable sideload keystore.
4. Future tagged releases will upgrade in place.

### Keystore setup (maintainers)

Release APKs must be signed with the **same keystore** for upgrades to work. Repository maintainers configure four GitHub Secrets:

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded `.jks` file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias (e.g. `upload`) |

Generate a keystore locally (never commit it):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

See [Developer setup](/docs/developer-setup) for full release instructions.

## Android Auto Backup

List Pilot enables Android Auto Backup (`allowBackup="true"`) as a secondary safety net. Primary data preservation relies on in-place upgrades.

## Version codes

Version numbers use semver (`X.Y.Z`). The Android build number is `major*10000 + minor*100 + patch`. Keep patch below 100 to avoid versionCode collisions.
