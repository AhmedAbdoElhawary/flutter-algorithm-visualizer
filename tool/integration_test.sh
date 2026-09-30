#!/usr/bin/env bash
#
# Runs the integration journeys on the one connected Android emulator, against
# local Firebase emulators for the fake "demo-algodive" project.
#
# Needs: one device in `adb devices`, Java 21, and firebase-tools on the PATH.
#
# The real dev google-services.json and the local firebase.json are swapped for
# the ones in tool/integration/ and put back on any exit, so `git status` stays
# clean.

set -euo pipefail

cd "$(dirname "$0")/.."

swapped=(
  "android/app/src/dev/google-services.json:tool/integration/google-services.demo.json"
  "firebase.json:tool/integration/firebase.json"
)
backup=$(mktemp -d)

restore() {
  adb shell cmd connectivity airplane-mode disable >/dev/null 2>&1 || true
  for pair in "${swapped[@]}"; do
    target=${pair%%:*}
    if [[ -f "$backup/$(basename "$target")" ]]; then
      cp "$backup/$(basename "$target")" "$target"
    else
      rm -f "$target"
    fi
  done
  rm -rf "$backup"
  echo "restored"
}
trap restore EXIT INT TERM

for pair in "${swapped[@]}"; do
  target=${pair%%:*}
  [[ -f "$target" ]] && cp "$target" "$backup/$(basename "$target")"
  cp "${pair#*:}" "$target"
done

flags="--flavor dev --dart-define-from-file=dart_define/dev.json --dart-define=USE_FIREBASE_EMULATOR=true"

firebase emulators:exec --project demo-algodive --only auth,firestore \
  "flutter test integration_test/app_test.dart $flags"

adb shell cmd connectivity airplane-mode enable
firebase emulators:exec --project demo-algodive --only auth,firestore \
  "flutter test integration_test/offline_test.dart $flags"
