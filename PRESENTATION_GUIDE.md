# Automating Flutter Delivery with Production CI/CD — Presentation & Demo Guide

This repository (`relay_mobile`) contains a complete, **100% free-to-run** Production CI/CD implementation for Flutter, an interactive HTML slide deck, and a live local pipeline simulator for your presentation tomorrow.

---

## 📁 What Has Been Implemented in This Repo

1. **[lib/config/app_config.dart](lib/config/app_config.dart)** — Compile-time environment configuration using `--dart-define` (`APP_ENV`, `APP_VERSION`, `BUILD_NUMBER`, `GIT_COMMIT`, `API_BASE_URL`).
2. **[lib/main.dart](lib/main.dart)** — **Relay Mobile CI/CD Dashboard UI** that dynamically adapts its theme color, badge, and API endpoint for `DEV` (Blue), `STAGING` (Amber), and `PROD` (Emerald Green), plus an interactive environment switcher for live demos.
3. **[test/widget_test.dart](test/widget_test.dart)** — Unit and Widget test suite verifying environment parsing, version metadata formatting, counter state, and live UI environment switching.
4. **[android/app/build.gradle.kts](android/app/build.gradle.kts)** — Production Android release signing configuration that loads `android/key.properties` in CI and safely falls back to debug keys locally.
5. **[.github/workflows/ci.yml](.github/workflows/ci.yml)** — Continuous Integration workflow triggered on every Pull Request & push (`dart format`, `flutter analyze --fatal-infos`, `flutter test --coverage`, and an automated **>= 80% coverage threshold gate**).
6. **[.github/workflows/cd_release.yml](.github/workflows/cd_release.yml)** — Continuous Delivery workflow triggered on version tags (`v*.*.*`) or manual 1-click dispatch (`workflow_dispatch`) to build signed Android APKs/AABs, Flutter Web bundles, and publish GitHub Releases.
7. **[scripts/run_ci_demo.sh](scripts/run_ci_demo.sh)** — Color-coded local CI/CD pipeline simulator for fast, reliable live stage demos (~20 seconds, zero internet required).
8. **[scripts/generate_keystore.sh](scripts/generate_keystore.sh)** — One-command Android Release Keystore (`.jks`) + Base64 GitHub Secret generator.
9. **[presentation/slides.html](presentation/slides.html)** — Interactive 9-slide presentation deck with built-in Speaker Notes (`S` key) and Fullscreen mode (`F` key).

---

## 🖥️ How to Open the Slide Deck Tomorrow

Run this command in your terminal (or double-click `presentation/slides.html` in Finder):

```bash
open presentation/slides.html
```

- Press **`→` (Right Arrow)** or **`Space`** to advance slides.
- Press **`←` (Left Arrow)** to go back.
- Press **`S`** to toggle the **Speaker Script Bar** at the bottom of the screen.
- Press **`F`** to enter **Fullscreen mode**.

---

## 🎬 Step-by-Step Live Demonstration Script (5–7 Minutes)

During **Slide 8 ("What We Will See in the Live Demo")**, switch to your IDE / Terminal and run these 3 quick demos:

### Demo Part 1: Show the Multi-Environment Flutter App (2 mins)
Run the app in Chrome (or macOS / Simulator) with production `--dart-define` flags injected:

```bash
flutter run -d chrome \
  --dart-define=APP_ENV=staging \
  --dart-define=APP_VERSION=1.4.0 \
  --dart-define=BUILD_NUMBER=88 \
  --dart-define=GIT_COMMIT=9f8e7d6
```

**What to point out to the audience:**
- Point to the **Amber `STAGING / QA` badge** and the injected `v1.4.0+88 (9f8e7d6)` version string.
- Click the **`DEV`**, **`STAGING`**, and **`PROD`** segmented buttons inside the app to show how the theme color, icon, and API endpoint (`https://api.relay.io`) switch automatically.

---

### Demo Part 2: Run the Automated CI/CD Pipeline Live in Terminal (2 mins)
Run the local CI/CD simulator script so the audience sees every quality gate execute in real time:

```bash
./scripts/run_ci_demo.sh --env=prod
```

**What to point out as it runs:**
1. **Stage 1 (`dart format`)**: Checks that no unformatted files exist.
2. **Stage 2 (`flutter analyze --fatal-infos`)**: Zero static analysis warnings.
3. **Stage 3 (`flutter test --coverage`)**: Runs unit + widget tests and calculates exact line coverage from `coverage/lcov.info` (passes the `>= 80%` gate).
4. **Stage 4 (`flutter build web --release`)**: Compiles the production artifact with `--dart-define` metadata injected.

*(Optional Bonus)*: Add an unused variable `int x = 1;` in `lib/main.dart` and re-run `./scripts/run_ci_demo.sh` to show the audience how **Stage 2 immediately blocks the pipeline** before a broken build can ever be created! Then remove the line and re-run.

---

## 📲 Complete Command Cheat Sheet: Every Environment (`dev`, `staging`, `prod`) on Android & iOS

### 1. Automated CI/CD Pipeline Commands (Builds Release Artifacts)

| Environment | Android Only (Fast ~15s) | Both Android APK + iOS App (~35s) |
| :--- | :--- | :--- |
| **DEV (Blue)** | `./scripts/run_ci_demo.sh --env=dev` | `./scripts/run_ci_demo.sh --env=dev --with-ios` |
| **STAGING (Amber)** | `./scripts/run_ci_demo.sh --env=staging` | `./scripts/run_ci_demo.sh --env=staging --with-ios` |
| **PROD (Green)** | `./scripts/run_ci_demo.sh --env=prod` | `./scripts/run_ci_demo.sh --env=prod --with-ios` |

---

### 2. Android Commands (Connected Phone: `SM E166P` / `R9ZY30RQ0EW`)

#### Option A: Run Live with Hot-Reload on Android Phone
* **DEVELOPMENT (Blue Theme • `api.dev.relay.internal`)**
  ```bash
  flutter run -d R9ZY30RQ0EW \
    --dart-define=APP_ENV=dev \
    --dart-define=APP_VERSION=1.2.0-dev \
    --dart-define=BUILD_NUMBER=10 \
    --dart-define=GIT_COMMIT=dev101a
  ```
* **STAGING / QA (Amber Theme • `api.staging.relay.internal`)**
  ```bash
  flutter run -d R9ZY30RQ0EW \
    --dart-define=APP_ENV=staging \
    --dart-define=APP_VERSION=1.2.0-rc1 \
    --dart-define=BUILD_NUMBER=25 \
    --dart-define=GIT_COMMIT=stg205b
  ```
* **PRODUCTION (Emerald Green Theme • `api.relay.io`)**
  ```bash
  flutter run -d R9ZY30RQ0EW \
    --dart-define=APP_ENV=prod \
    --dart-define=APP_VERSION=1.2.0 \
    --dart-define=BUILD_NUMBER=42 \
    --dart-define=GIT_COMMIT=prd998f
  ```

#### Option B: Build Release APK & Install on Android Phone
1. **Build DEV Release APK & Install:**
   ```bash
   ./scripts/run_ci_demo.sh --env=dev
   flutter install -d R9ZY30RQ0EW --use-application-binary=build/app/outputs/flutter-apk/app-release.apk
   ```
2. **Build STAGING Release APK & Install:**
   ```bash
   ./scripts/run_ci_demo.sh --env=staging
   flutter install -d R9ZY30RQ0EW --use-application-binary=build/app/outputs/flutter-apk/app-release.apk
   ```
3. **Build PROD Release APK & Install:**
   ```bash
   ./scripts/run_ci_demo.sh --env=prod
   flutter install -d R9ZY30RQ0EW --use-application-binary=build/app/outputs/flutter-apk/app-release.apk
   ```

---

### 3. iOS Commands (iOS Simulator & Physical iPhone)

#### Step 0: Open iOS Simulator (or Plug In Your iPhone)
```bash
# Open Xcode DeviceHub / Simulator manager:
open /Applications/Xcode.app/Contents/Applications/DeviceHub.app

# Check your active iOS device ID (Simulator or Physical iPhone):
flutter devices
```

#### Option A: Run on iOS Simulator (or Physical iPhone) for Each Environment
Replace `ios` below with your specific Simulator ID or iPhone ID (e.g., `00008020-000D6C203688002E` for your `Epic Xs max`) if multiple iOS devices are connected:

* **DEVELOPMENT (Blue Theme)**
  ```bash
  flutter run -d ios \
    --dart-define=APP_ENV=dev \
    --dart-define=APP_VERSION=1.2.0-dev \
    --dart-define=BUILD_NUMBER=10 \
    --dart-define=GIT_COMMIT=dev101a
  ```
* **STAGING / QA (Amber Theme)**
  ```bash
  flutter run -d ios \
    --dart-define=APP_ENV=staging \
    --dart-define=APP_VERSION=1.2.0-rc1 \
    --dart-define=BUILD_NUMBER=25 \
    --dart-define=GIT_COMMIT=stg205b
  ```
* **PRODUCTION (Emerald Green Theme)**
  ```bash
  flutter run -d ios \
    --dart-define=APP_ENV=prod \
    --dart-define=APP_VERSION=1.2.0 \
    --dart-define=BUILD_NUMBER=42 \
    --dart-define=GIT_COMMIT=prd998f
  ```

#### Option B: Build & Install Release Mode on Physical iPhone
*(Note: Installing onto a physical iPhone requires selecting your free Personal Team under `Runner` → `Signing & Capabilities` in `open ios/Runner.xcworkspace`, then running)*:
```bash
# Install PROD Release build directly onto connected iPhone:
flutter run --release -d 00008020-000D6C203688002E \
  --dart-define=APP_ENV=prod \
  --dart-define=APP_VERSION=1.2.0 \
  --dart-define=BUILD_NUMBER=42 \
  --dart-define=GIT_COMMIT=prd998f
```

1. Open [`.github/workflows/ci.yml`](.github/workflows/ci.yml) and [`.github/workflows/cd_release.yml`](.github/workflows/cd_release.yml) in your editor.
2. Run the keystore generator script in terminal to show how release signing keys are prepared for GitHub Secrets:
   ```bash
   ./scripts/generate_keystore.sh
   ```
3. If you push this repository to a free GitHub account before tomorrow:
   ```bash
   git init
   git add .
   git commit -m "feat: add production Flutter CI/CD pipeline"
   # Push to your free GitHub repo, then trigger a release tag:
   git tag v1.0.0
   git push origin main --tags
   ```
   Open the **Actions** tab and **Releases** tab on GitHub to show the green checkmarks, the Markdown coverage report summary, and the downloadable `app-release.apk` & `app-release.aab`!

