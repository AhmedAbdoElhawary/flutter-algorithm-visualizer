#!/bin/sh
set -e

# Copies the correct GoogleService-Info.plist into place for the flavor being
# built, based on the active Xcode build configuration ($CONFIGURATION), e.g.
# "Debug-dev", "Release-staging", "Release-production".
#
# Wired up as the "Firebase config (per flavor)" Run Script build phase on
# the Runner target (see project.pbxproj), placed right before "Thin Binary".
# This project has no CocoaPods build phases (removed in an earlier commit;
# plugins link via FlutterGeneratedPluginSwiftPackage instead), so there's no
# "[CP] Embed Pods Frameworks" to anchor on — just before the final packaging
# step is the equivalent spot.
#
# Source files:
#   ios/Runner/Firebase/dev/GoogleService-Info.plist
#   ios/Runner/Firebase/staging/GoogleService-Info.plist
#   ios/Runner/Firebase/production/GoogleService-Info.plist
#
# Destination (git-ignored, read by Firebase.initializeApp() and bundled):
#   ios/Runner/GoogleService-Info.plist

case "${CONFIGURATION}" in
  *-dev|*Dev) FLAVOR="dev" ;;
  *-staging|*Staging) FLAVOR="staging" ;;
  *) FLAVOR="production" ;;   # plain Debug/Release/Profile => production
esac

SRC="${SRCROOT}/Runner/Firebase/${FLAVOR}/GoogleService-Info.plist"
DEST="${SRCROOT}/Runner/GoogleService-Info.plist"

if [ ! -f "${SRC}" ]; then
  echo "error: ${SRC} not found. Download it from the ${FLAVOR} Firebase project and place it there."
  exit 1
fi

cp "${SRC}" "${DEST}"
echo "Firebase: using ${FLAVOR} GoogleService-Info.plist (CONFIGURATION=${CONFIGURATION})"

# Also copy into the built .app so the plist is available at runtime.
if [ -n "${BUILT_PRODUCTS_DIR}" ] && [ -n "${PRODUCT_NAME}" ]; then
  cp "${SRC}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi
