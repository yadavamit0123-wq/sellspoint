# Build APK / AAB from GitHub Actions

Use this when local Mac cannot run Flutter/Android builds.

## One-time setup

### 1. Push the workflow

Ensure `.github/workflows/android-build.yml` is on the branch you build from (e.g. `rebase/eclassify-2.14-base` or `main`).

### 2. Add GitHub Secrets

Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret name | Value |
|-------------|--------|
| `ANDROID_KEYSTORE_BASE64` | Base64 of `android/app/prt.jks` (see below) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password from `android/key.properties` |
| `ANDROID_KEY_PASSWORD` | Key password from `android/key.properties` |
| `ANDROID_KEY_ALIAS` | Key alias (e.g. `key0`) |

**Create BASE64 on any Mac/PC** (from project root):

```bash
base64 -i android/app/prt.jks | pbcopy   # macOS — copied to clipboard
# Linux:
base64 -w 0 android/app/prt.jks
```

Paste the full string into `ANDROID_KEYSTORE_BASE64`.

> Never commit `prt.jks` or `key.properties` to GitHub.

### 3. Debug APK only (no secrets)

Choose **debug-apk** — no signing secrets required. For Play Store use **release-aab** with secrets.

## Run a build

1. GitHub repo → **Actions**
2. Left sidebar: **Build Android APK / AAB**
3. **Run workflow**
4. Branch: `rebase/eclassify-2.14-base` (or `main`)
5. Build type:
   - `debug-apk` — test install on phone
   - `release-apk` — signed release APK
   - `release-aab` — Play Store upload
   - `all` — debug APK + release APK + AAB
6. Wait ~15–30 minutes (first run may be slower)
7. Open the completed run → **Artifacts** → download zip

## Output files

| Artifact | File inside |
|----------|-------------|
| sellspoint-debug-apk | `app-debug.apk` |
| sellspoint-release-apk | `app-release.apk` |
| sellspoint-release-aab | `app-release.aab` |

Upload **app-release.aab** to Google Play Console.

## Flutter / Dart SDK on GitHub Actions

The workflow pins **Flutter 3.47.1** (Dart **3.13.1**).

| Flutter | Dart | Result |
|---------|------|--------|
| 3.32.0 | 3.8.0 | `flutter_stripe` fails (needs ≥3.8.1) |
| 3.32.8 | 3.8.1 | `google_mobile_ads` fails (needs ≥3.9 / 3.10) |
| 3.47.1 | 3.13.1 | Matches current `pubspec.yaml`; needs AGP **8.11.1+** and Kotlin **2.4.0+** |

After changing `.github/workflows/android-build.yml`, push the branch and re-run the workflow **on that same branch**. Running an old commit on `main` will keep failing.

## AGP 9 build error on GitHub Actions

If you see `Starting AGP 9+, only the new DSL interface will be read`, ensure `android/gradle.properties` includes:

```
android.newDsl=false
android.builtInKotlin=false
```

Then push and re-run the workflow.
