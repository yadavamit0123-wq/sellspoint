# App rebase R3 — settings, Firebase, assets, package id locked

**Branch:** `rebase/eclassify-2.14-base`  
**Date:** 2026-08-19  
**Status:** Done (local)

## Goal

Lock Sells Point production identity on the 2.14 base: config single source of truth, native IDs, Firebase init, branding, and assets — without wiring custom modules (R4).

## Changes applied

### Config bridge

| File | Change |
|------|--------|
| `lib/settings.dart` | Documented as production source of truth (URLs, name, package, share text) |
| `lib/app_config.dart` | Reads from `AppSettings`; lat/long → `0.0` (admin defaults); no duplicate URLs |

Locked production values (via `AppSettings`):

- App name: **Sells Point**
- Admin: `https://admin.sellspoint.in`
- Share web: `sellspoint.in` → `https://sellspoint.in`
- Package: `com.pt.sellspoint`

### Firebase

| File | Change |
|------|--------|
| `lib/app/app.dart` | Fixed inverted Firebase init — always pass `DefaultFirebaseOptions.currentPlatform` on cold start |
| `docs/merge/rebase_preserve/FIREBASE_LOCK.md` | Documents Android `sells-point` vs Dart/iOS `eclassify-wrteam` split (preserved from live) |

**Not changed (locked from preserve):** `lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`.

### Android

| Item | Value / action |
|------|----------------|
| `applicationId` / `namespace` | `com.pt.sellspoint` (unchanged) |
| `MainActivity.kt` | Moved to `kotlin/com/pt/sellspoint/` |
| `versionCode` / `versionName` | **`18`** / **`2.0.2`** (aligned with `pubspec.yaml`) |
| Manifest label | `Sells Point` |
| Deep links | `sellspoint://sellspoint.in/product-details/*` |
| Permissions | Added `CAMERA`, `POST_NOTIFICATIONS` (2.14) |
| Deep linking meta | `flutter_deeplinking_enabled=true` |

### iOS

| Item | Before | After |
|------|--------|-------|
| Display name | eClassify | **Sells Point** |
| URL scheme | `eclassify` | **`sellspoint`** |
| Associated domains | vendor + admin | **`applinks:sellspoint.in`**, `applinks:admin.sellspoint.in` |
| Bundle ID | `com.pt.sellspoint` | unchanged |

### Assets & pubspec

| Item | Status |
|------|--------|
| `assets/icons/branding/logo.svg` | MD5 matches preserve |
| `assets/icons/branding/company_logo.svg` | MD5 matches preserve |
| Legacy `assets/svg/Logo/*` | Present (status module) |
| `pubspec.yaml` | Description → “Sells Point — buy and sell locally”; version **`2.0.2+18`**; `name: eClassify` unchanged (Dart package id) |

## Verified unchanged (correct)

- Android `google-services.json` → `sells-point` / `com.pt.sellspoint`
- iOS `GoogleService-Info.plist` → `eclassify-wrteam` / `com.pt.sellspoint`
- Maps API key in manifest matches `firebase_options.dart` Android key

## Known remnants (non-blocking for R3)

- `package:eClassify/...` imports (2.14 convention; not user-visible)
- Language JSON keys like `loginToeClassify` (admin/localization; update in R6 QA if desired)
- Referral/wallet/status modules still not wired (R4)

## Local verify

```bash
cd "/Users/amityadav/Projects/Sells Point/sellspoint"
flutter pub get
flutter analyze   # compile errors until R4
```

## Rebase track

| Phase | Status |
|-------|--------|
| R1–R2 | Done |
| **R3** | **Done** |
| R4 | Next — wire Status / Referral / Wallet into 2.14 nav |
