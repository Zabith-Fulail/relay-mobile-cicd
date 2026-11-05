#!/usr/bin/env bash
# ==============================================================================
# VaultOps — Live Mobile CI/CD Pipeline Runner (Android & iOS)
# Usage:
#   ./scripts/run_ci_demo.sh                                       # Full Mobile CI/CD (prod v1.2.0+42)
#   ./scripts/run_ci_demo.sh --env=prod --version=2.0.0 --build=101 # Custom Production Release
#   ./scripts/run_ci_demo.sh --env=staging                         # Staging Build
#   ./scripts/run_ci_demo.sh --with-ios                            # Also builds iOS Release Archive
# ==============================================================================

set -euo pipefail

# ANSI Colors for Presentation Terminal Output
BOLD="\033[1m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

CURRENT_STAGE="Initialization"

on_error() {
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${RED}${BOLD}  ✖ PIPELINE BLOCKED AT: ${CURRENT_STAGE}${RESET}"
  echo -e "${RED}  Quality gate failed — mobile release build was aborted to protect production.${RESET}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}
trap on_error ERR

APP_ENV="prod"
APP_VERSION="1.2.0"
BUILD_NUMBER="42"
WITH_IOS=false

for arg in "$@"; do
  case $arg in
    --env=*)
      APP_ENV="${arg#*=}"
      ;;
    --version=*|-v=*)
      APP_VERSION="${arg#*=}"
      ;;
    --build=*|-b=*)
      BUILD_NUMBER="${arg#*=}"
      ;;
    --with-ios)
      WITH_IOS=true
      ;;
  esac
done

GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "demo7f3")

banner() {
  CURRENT_STAGE="$1"
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${CYAN}${BOLD}  $1${RESET}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

step_ok() {
  echo -e "${GREEN}✔ $1${RESET}"
}

echo -e "${BOLD}${CYAN}"
echo "  📱 VAULTOPS — AUTOMATED ANDROID & iOS CI/CD PIPELINE"
echo -e "${RESET}"
echo -e "  • Target Environment : ${YELLOW}${APP_ENV}${RESET}"
echo -e "  • Mobile Version     : ${YELLOW}v${APP_VERSION}+${BUILD_NUMBER}${RESET}"
echo -e "  • Git Commit SHA     : ${YELLOW}${GIT_COMMIT}${RESET}"

# ------------------------------------------------------------------------------
# STAGE 1: Code Formatting Gate
# ------------------------------------------------------------------------------
banner "STAGE 1/4: Code Formatting Gate (dart format)"
dart format lib test
dart format --output=none --set-exit-if-changed lib test
step_ok "All Dart files in lib/ and test/ adhere to style guidelines."

# ------------------------------------------------------------------------------
# STAGE 2: Static Code Analysis Gate
# ------------------------------------------------------------------------------
banner "STAGE 2/4: Static Analysis Gate (flutter analyze)"
flutter analyze --fatal-infos
step_ok "Zero static analysis warnings or errors found."

# ------------------------------------------------------------------------------
# STAGE 3: Automated Unit & Widget Tests + Coverage Gate
# ------------------------------------------------------------------------------
banner "STAGE 3/4: Automated Tests & Coverage Gate (flutter test --coverage)"
flutter test --coverage --reporter expanded

if [ -f coverage/lcov.info ]; then
  TOTAL_LINES=$(grep -E '^LF:' coverage/lcov.info | cut -d: -f2 | awk '{s+=$1} END {print s}')
  HIT_LINES=$(grep -E '^LH:' coverage/lcov.info | cut -d: -f2 | awk '{s+=$1} END {print s}')
  COVERAGE=$(awk "BEGIN {printf \"%.1f\", ($HIT_LINES / $TOTAL_LINES) * 100}")
  echo ""
  echo -e "  📊 ${BOLD}Line Coverage:${RESET} ${GREEN}${COVERAGE}%${RESET} (${HIT_LINES}/${TOTAL_LINES} lines) — Minimum threshold: 80.0%"
  PASS=$(awk "BEGIN {print ($COVERAGE >= 80.0) ? 1 : 0}")
  if [ "$PASS" -eq 0 ]; then
    echo -e "${RED}✖ Coverage ${COVERAGE}% is below the 80% quality gate!${RESET}"
    exit 1
  fi
  step_ok "Coverage gate passed (${COVERAGE}% >= 80.0%)."
fi

# ------------------------------------------------------------------------------
# STAGE 4: Mobile Release Build (Android APK & Optional iOS Archive)
# ------------------------------------------------------------------------------
banner "STAGE 4/4: Mobile Release Build & Signing (Android APK / iOS)"
echo -e "Injecting compile-time config: APP_ENV=${APP_ENV}, APP_VERSION=${APP_VERSION}, BUILD_NUMBER=${BUILD_NUMBER}, GIT_COMMIT=${GIT_COMMIT}"
echo ""
echo -e "📦 Building signed Android Release APK..."

flutter build apk --release \
  --build-name="${APP_VERSION}" \
  --build-number="${BUILD_NUMBER}" \
  --dart-define=APP_ENV="${APP_ENV}" \
  --dart-define=APP_VERSION="${APP_VERSION}" \
  --dart-define=BUILD_NUMBER="${BUILD_NUMBER}" \
  --dart-define=GIT_COMMIT="${GIT_COMMIT}"

step_ok "Android Release APK generated at: build/app/outputs/flutter-apk/app-release.apk"

if [ "$WITH_IOS" = true ]; then
  echo ""
  echo -e "🍎 Building iOS Release Archive (no-codesign)..."
  flutter build ios --release --no-codesign \
    --build-name="${APP_VERSION}" \
    --build-number="${BUILD_NUMBER}" \
    --dart-define=APP_ENV="${APP_ENV}" \
    --dart-define=APP_VERSION="${APP_VERSION}" \
    --dart-define=BUILD_NUMBER="${BUILD_NUMBER}" \
    --dart-define=GIT_COMMIT="${GIT_COMMIT}"
  step_ok "iOS Release app bundle generated at: build/ios/iphoneos/Runner.app"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  🎉 MOBILE PIPELINE SUCCEEDED! Release v${APP_VERSION}+${BUILD_NUMBER} (${APP_ENV}) is ready.${RESET}"
echo -e "${GREEN}  📲 Install built APK on connected Android phone:${RESET}"
echo -e "     flutter install -d R9ZY30RQ0EW --use-application-binary=build/app/outputs/flutter-apk/app-release.apk"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
