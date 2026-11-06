# Automating Flutter Delivery with Production CI/CD — Master Presentation Playbook

This repository (`vault_ops`) contains a complete, **100% production-ready** CI/CD setup for Flutter, an interactive 11-slide aesthetic presentation deck, Clean Architecture implementation, and live GitHub Actions / GitLab CI cloud integrations.

---

## 📁 Repository Architectural Overview

1. **[lib/domain/](lib/domain/)** — Pure enterprise domain models (`PipelineRun`, `ReleaseArtifact`, `KpiMetric`, `FeatureFlag`) and abstract repository interface (`ReleaseRepository`).
2. **[lib/data/](lib/data/)** — Concrete repository (`CiCdReleaseRepository`) and REST data source (`CiCdDataSource`) querying **live GitHub Actions & Releases APIs** (`api.github.com/repos/Zabith-Fulail/relay-mobile-cicd/...`) with offline resilience.
3. **[lib/ui/](lib/ui/)** — Clean Presentation layer (MVVM) featuring `DashboardViewModel`, Material 3 dynamic **Device System Theme** support, and modular tabs (`Overview`, `Pipelines`, `Flavors`, `Artifacts`).
4. **[lib/config/app_config.dart](lib/config/app_config.dart)** — Compile-time environment configuration via `--dart-define` (`APP_ENV`, `APP_VERSION`, `BUILD_NUMBER`, `GIT_COMMIT`, `API_BASE_URL`, `GITHUB_OWNER`, `GITHUB_REPO`).
5. **[.github/workflows/ci.yml](.github/workflows/ci.yml)** — Pull Request quality gate (`dart format`, `flutter analyze --fatal-infos`, `flutter test --coverage`, >=80% LCOV coverage gate).
6. **[.github/workflows/cd_release.yml](.github/workflows/cd_release.yml)** — Tag-triggered multi-platform delivery pipeline (`v*.*.*`) building signed Android APK/AAB and iOS archives, published to **GitHub Releases**.
7. **[.gitlab-ci.yml](.gitlab-ci.yml)** — Full GitLab CI/CD pipeline for enterprise / banking deployment (Bank2U CBC).
8. **[scripts/run_ci_demo.sh](scripts/run_ci_demo.sh)** — Terminal CI/CD pipeline simulator for instant offline stage execution.
9. **[presentation/slides.html](presentation/slides.html)** — Interactive 11-slide deck with built-in **Speaker Script Bar** (`S` key), **Theme Toggle** (`T` key), and **Fullscreen mode** (`F` key).

---

## 🖥️ How to Launch the Slide Deck

In your terminal, run:
```bash
open presentation/slides.html
```

* **Advance / Go Back:** Press **`→` (Right Arrow)** / **`Space`** or **`←` (Left Arrow)**.
* **Toggle Speaker Script Bar:** Press **`S`** (displays your exact talking notes at the bottom of the screen!).
* **Fullscreen Presentation Mode:** Press **`F`**.
* **Toggle Light/Dark Theme:** Press **`T`**.

---

## ⏱️ Step-by-Step Presentation Script (15–20 Minutes)

| Time | Slide | Focus | What to Say & Emphasize |
| :--- | :--- | :--- | :--- |
| **00:00 – 01:30** | **Slide 1: Title** | Intro | *"Welcome everyone! Today I will demonstrate how to automate Flutter mobile delivery with production CI/CD. We'll examine how teams move away from manual laptop releases into a zero-cost, fully automated cloud pipeline with Clean Architecture and live telemetry."* |
| **01:30 – 03:00** | **Slide 2: The Problem** | Pain Points | *"Why do manual Flutter builds fail? First, environment drift between developer machines. Second, skipped tests during rushed hotfixes. Third, staging URLs accidentally shipped to production. And fourth, keystores trapped on a single developer's laptop."* |
| **03:00 – 04:30** | **Slide 3: Pipeline Blueprint** | Two Workflows | *"Our pipeline divides automation into two specialized GitHub Actions workflows: `ci.yml` for fast sub-2-minute PR feedback, and `cd_release.yml` triggered by Git tags (`v*.*.*`) to build and sign Android APK/AAB and iOS archives."* |
| **04:30 – 06:00** | **Slide 4: Quality Gates** | Enforcement | *"Stage 1 enforces four non-negotiable gates: `dart format`, `flutter analyze --fatal-infos`, unit and widget tests, and an automated bash script that parses `coverage/lcov.info` and fails the PR if line coverage drops below 80%."* |
| **06:00 – 08:00** | **Slide 5: Case Study** | Real-World Incident | *(The Silent Bug Caught by CI — See Detailed Story Below!)* *"Now let me share a real incident from our project that proves why CI/CD matters. Nobody on our team wrote a test for ink ripple effects. But when our cloud CI runner tested our app, Flutter's internal SDK assertions detected that a switch tile was inside an opaque container, which would have hidden tap ripples from users. The CI gate failed the build, blocked the release, we fixed it with a transparent Material wrapper, and production was saved!"* |
| **08:00 – 09:30** | **Slide 6: Clean Architecture** | Code Quality | *"To keep the app maintainable, we adopted Clean Architecture: pure Domain models with Dependency Inversion, a Data layer connecting directly to the GitHub REST API, and an MVVM Presentation layer that adapts automatically to the device's Dark/Light system theme."* |
| **09:30 – 11:00** | **Slide 7: Multi-Env Config** | `--dart-define` | *"Instead of dangerous manual configuration edits, we use compile-time `--dart-define` flags. The CI pipeline injects `APP_ENV`, `APP_VERSION`, `BUILD_NUMBER`, and `GIT_COMMIT` directly into the binary at build time."* |
| **11:00 – 12:30** | **Slide 8: Zero-Touch Signing** | Security | *"Keystores and passwords never touch Git. We Base64-encode the release keystore into GitHub Secrets, decode it in runner RAM during the build, and use a safe Gradle fallback so local developer builds never break."* |
| **12:30 – 14:00** | **Slide 9: Cloud Delivery** | GitHub Actions | *"When a release tag like `v1.0.0` is pushed, GitHub Actions compiles the signed binaries and attaches them to GitHub Releases. The mobile app queries this API in real time to show live workflow runs and download counts."* |
| **14:00 – 18:00** | **Slide 10: Live Demo** | Interactive Demo | *(Switch from browser to mobile app and terminal — see Live Demo Runbook below!)* |
| **18:00 – 20:00** | **Slide 11: Conclusion** | Q&A | *"To wrap up: automate PR gates first, inject environment configs via `--dart-define`, secure signing keys in CI secrets, and adopt Clean Architecture. Thank you! I'm now open for questions."* |

---

## 💡 How to Explain the Case Study (Slide 5: The Silent Bug)

When you arrive at **Slide 5**, use this exact explanation to captivate the audience:

1. **Set the Stage**:
   > *"Many engineers ask: 'Why should I bother setting up CI/CD if I already test my code locally?' Let me share an actual bug our CI/CD caught in this very project."*
2. **The Mystery**:
   > *"During our build verification, GitHub Actions suddenly failed with an assertion error: 'ListTile background color or ink splashes may be invisible.' We didn't write any test looking for tap ripples. So how did this happen?"*
3. **The Engineering Explanation**:
   > *"In our Flavors tab, we had four feature flag switches wrapped inside a styled Container with a colored background. In Flutter, tap ripples (ink splashes) are painted on the nearest Material canvas. Our container's background color was secretly painting over the ripple, making it completely invisible to users! In a local release build, Flutter strips out assertions, so we never would have seen it. But in CI/CD, the cloud runner executes `flutter test` in strict debug mode. Flutter's own internal framework assertions audited our widget tree, caught the invisible ripple, and crashed the test."*
4. **The Punchline**:
   > *"Because our quality gate was active, the pipeline exited with code 1 and refused to deploy. We wrapped the tile in a transparent Material widget, the test passed, and our users received a flawless UI. That is the true value of CI/CD: it catches framework-level defects automatically, without you having to write a test for every single rule!"*

---

## 🎬 Step-by-Step Live Demonstration Runbook (Slide 10)

### Part 1: Show the Live Cloud GitHub Console (2 mins)
1. Open in your browser:
   👉 **`https://github.com/Zabith-Fulail/relay-mobile-cicd/actions`**
   * Point out the **`CD — Mobile Multi-Environment Build & Release`** run with its 4-stage visual pipeline graph:
     * `1. Quality Gate (Analyze & Test)`
     * `2. Build Android Release (APK + AAB)`
     * `3. Build iOS Release Archive`
     * `4. Publish GitHub Release & Store Distribution`
2. Open the Releases tab:
   👉 **`https://github.com/Zabith-Fulail/relay-mobile-cicd/releases`**
   * Show release **`v1.0.0`** with downloadable **`relay-mobile-prod-v1.0.0.apk`** and **`relay-mobile-prod-v1.0.0.aab`** assets.

---

### Part 2: Showcase the Mobile App on Phone or Simulator (2 mins)
Launch the app with injected CI/CD flags:
```bash
flutter run -d R9ZY30RQ0EW \
  --dart-define=APP_ENV=staging \
  --dart-define=APP_VERSION=1.4.0 \
  --dart-define=BUILD_NUMBER=88 \
  --dart-define=GIT_COMMIT=9f8e7d6
```

**Walk the audience through the 4 tabs:**
1. **Overview Tab:**
   * Point to the **Amber `STAGING / QA` theme**, the `v1.4.0+88 (9f8e7d6)` release stamp, and the `api.staging.relay.internal` endpoint.
   * Tap the **`DEV`**, **`STAGING`**, and **`PROD`** buttons to show how the app theme and API URLs adapt instantly.
   * Tap the **Theme Mode button** in the AppBar to show seamless transitions between **System (Auto)**, **Light**, and **Dark** modes.
2. **Pipelines Tab:**
   * Tap the **`Run CI/CD`** button to show the interactive pipeline simulator animating through Stages 1 ➔ 4.
   * Show the recent workflow runs fetched live from the GitHub Actions REST API.
3. **Flavors Tab:**
   * Inspect the `--dart-define` compile-time flag matrix and toggle the live feature switches (`Impeller Hardware Vulkan`, `OTA Patching`).
4. **Artifacts Tab:**
   * Inspect the signed binaries (`.apk`, `.aab`, `.ipa`) with sizes and verified checksums.

---

### Part 3: Run the Terminal Pipeline Simulator Live (1 min)
In terminal, run the local CI runner to show all 4 quality gates passing in real time:
```bash
./scripts/run_ci_demo.sh --env=prod --with-ios
```
* **Stage 1 (Format):** `dart format` verifies style.
* **Stage 2 (Analyze):** `flutter analyze --fatal-infos` enforces 0 lint issues.
* **Stage 3 (Tests & Coverage):** 5 unit & widget tests pass with **98.0% line coverage** (`>= 80%` gate).
* **Stage 4 (Build & Sign):** Compiles the production Android APK and iOS release archive.
* Finishes with the vibrant green **`🎉 MOBILE PIPELINE SUCCEEDED!`** banner!
