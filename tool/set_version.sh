#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <tag-or-version>" >&2
  echo "Example: $0 v1.2.3" >&2
  exit 1
fi

input="$1"
version="${input#v}"

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: $input (expected vX.Y.Z or X.Y.Z)" >&2
  exit 1
fi

IFS='.' read -r major minor patch <<< "$version"
build_number=$((major * 10000 + minor * 100 + patch))

root="$(cd "$(dirname "$0")/.." && pwd)"
pubspec="$root/pubspec.yaml"

if [[ ! -f "$pubspec" ]]; then
  echo "pubspec.yaml not found at $pubspec" >&2
  exit 1
fi

new_version="version: ${version}+${build_number}"
if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i '' "s/^version: .*/${new_version}/" "$pubspec"
else
  sed -i "s/^version: .*/${new_version}/" "$pubspec"
fi

echo "${version}+${build_number}"
