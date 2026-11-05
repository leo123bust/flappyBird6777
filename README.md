# Flappy 67

A Flappy Bird-inspired pixel-art game for Android, built with Flutter and Dart.
The look (sky gradient, chunky pixel birds, green pipes, grass/dirt ground, gold
"67" logo, 3D yellow/green/blue buttons, dark Best/Score panel, Skins grid) follows
the supplied four-screen reference image.

> **Status:** the code was written and statically checked (imports, asset paths,
> bracket balance) but **has not been compiled or run** - the environment it was
> produced in has no Flutter SDK. Expect to run `flutter pub get` and possibly fix
> small issues on first build. No APK is included for the same reason.

## Screens

| Screen | What it does |
|---|---|
| Splash | Logo, flapping bird, "Tap to fly!", **Get Started** |
| How to Play | Shown on first launch, and from Settings (gear icon) |
| Home | Best / Score panel, **Play**, Statistics (bars), Trophies, Skins (star), Settings (gear) |
| Game | Tap to flap, score counter, game-over panel with **Play again** / **Home** |
| Skins | 2x3 grid, prices 100 / 100 / 200 / 200 / 300, coin counter, selected-skin check |

Gameplay: gravity + tap-to-flap, randomised pipe gaps, collision detection, best
score (saved), coins (1 per pipe, saved), difficulty that rises with the score
(pipe speed 150 -> 210, gap 180 -> 140). Vibration feedback can be switched off in Settings.

## Requirements

- Flutter 3.24 or newer (Dart 3.5+) - run `flutter --version` to check
- Android Studio or VS Code with the Flutter plugin
- Android SDK (API 35) and JDK 17 (bundled with Android Studio)
- Dependencies: `flutter`, `shared_preferences` (see `pubspec.yaml`)

## Setup

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Run `flutter doctor` and fix anything it reports (Android toolchain + licences:
   `flutter doctor --android-licenses`).
3. Unzip the project and open the `flappy_67` folder in Android Studio / VS Code.
4. Fetch dependencies:

   ```bash
   flutter pub get
   ```

## Run

Connect an Android 12-15 phone (USB debugging on) or start an emulator, then:

```bash
flutter run
```

## Build an APK

```bash
flutter build apk --release
```

Result: `build/app/outputs/flutter-apk/app-release.apk`. Install it with
`adb install build/app/outputs/flutter-apk/app-release.apk`.

For Google Play use `flutter build appbundle` and replace the debug signing config
in `android/app/build.gradle.kts` with your own keystore
(https://docs.flutter.dev/deployment/android#sign-the-app).

## Android configuration

- `minSdk 31` (Android 12) / `targetSdk 35` (Android 15)
- Portrait only (`android:screenOrientation="portrait"` + `SystemChrome`)
- **No permissions** in the release manifest. The `INTERNET` permission appears only
  in the debug/profile manifests that Flutter itself needs for hot reload.
- Edge-to-edge system bars, no ads, fully offline

If Gradle reports a version mismatch with your Flutter SDK, regenerate the Android
wrapper files and re-apply the settings above (min/target SDK, portrait):

```bash
mv android android_backup
flutter create --platforms=android --org com.flappy67 --project-name flappy_67 .
```

Then copy `android_backup/app/src/main/res/mipmap-*` back and set `minSdk = 31`
in `android/app/build.gradle.kts`.

## Project structure

```
pubspec.yaml
analysis_options.yaml
assets/images/            bird_<skin>_<frame>.png  (6 skins x 3 wing frames, 20x14 px)
tools/generate_assets.py  regenerates sprites + launcher icons (needs Pillow)
android/                  Gradle + manifest + launcher icons
lib/
  main.dart               start-up: orientation, system bars, storage, sprites
  core/
    theme.dart            colours, UI scaling, fade route
    game_data.dart        best score, coins, skins, settings (shared_preferences)
    sprites.dart          loads the bird PNGs as ui.Image
  game/
    game_engine.dart      physics, pipes, scoring, collisions, difficulty
    game_painter.dart     draws the world on a CustomPainter at 60 FPS
  widgets/
    ui.dart               outlined text, 3D buttons, score panel, coin pill, bird
    scenery.dart          sky, clouds, city, bushes, pipes, ground
  screens/                splash, home, how_to_play, skins, game
```

## Design notes and tuning

- The game world is always 800 units tall and scaled to the screen, so the game
  plays identically on every phone. Tune it in `lib/game/game_engine.dart`
  (`gravity`, `flapVelocity`, `speed`, `gap`).
- Rendering uses one `CustomPainter` driven by a `Ticker` - no widget rebuilds per
  frame. Sprites are drawn with nearest-neighbour filtering to keep pixels crisp.
- **Typography:** the reference uses a heavy rounded display font. No font could be
  downloaded when this was built, so the app uses the system font in weight 900
  with a navy outline and drop shadow. To match the reference more closely, add a
  font such as *Lilita One* or *Baloo 2* under `assets/fonts/`, declare it in
  `pubspec.yaml`, and set `fontFamily` in `OutlinedText` (`lib/widgets/ui.dart`).
- The bird art is generated procedurally by `tools/generate_assets.py` to echo the
  reference sprites; replace the PNGs in `assets/images/` (same names, 20x14) to use
  your own artwork.

## Build the APK with GitHub Actions (no local Flutter needed)

The repo contains `.github/workflows/build-apk.yml`. Push the project to GitHub
(or upload `flappy_67_project.zip` to a repo together with that workflow file),
open **Actions > Build Android APK**, and when it finishes download
`flappy_67.apk` from **Releases**. Full phone-friendly steps are in
`HOW_TO_BUILD_APK_ON_GITHUB.md`.
