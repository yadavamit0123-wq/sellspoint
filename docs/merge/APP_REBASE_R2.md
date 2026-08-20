# App rebase R2 — 2.14 base applied

**Branch:** `rebase/eclassify-2.14-base`  
**Date:** 2026-08-19  
**Status:** Done (local)

## Goal

Replace the hybrid incremental merge with a **stock eClassify 2.14 `lib/` tree**, then restore Sells Point-only modules and production config. UI/navigation wiring is **R4**; this phase is base + preserve only.

## Source

| Item | Path |
|------|------|
| 2.14 app source | `/Users/amityadav/Projects/Sells Point/sellspoint new /eClassify-App-SourceCode-2.14.0` |
| Preserve bundle | `docs/merge/rebase_preserve/` |
| Hybrid backup | `docs/merge/rebase_preserve/hybrid-lib-backup.tar.gz` (~465 KB) |

## Actions performed

1. **Backed up** hybrid `lib/` → `rebase_preserve/hybrid-lib-backup.tar.gz`
2. **Backed up** hybrid `pubspec.yaml` → `rebase_preserve/pubspec.hybrid.yaml`
3. **Replaced** `lib/` with 2.14 source (526 Dart files)
4. **Restored Sells Point extras** (+13 files → 539 total):
   - `lib/settings.dart` — legacy config (URLs, package name, invite text)
   - `lib/firebase_options.dart`
   - `lib/app/sells_point_modules.dart`
   - `lib/new_development/status/` — Status stories
   - `lib/ui/screens/referral_program/`
   - `lib/ui/screens/my_wallet/`
   - `lib/data/cubits/referral/`, `lib/data/cubits/my_wallet/`
5. **Synced** `pubspec.yaml` from 2.14; kept live version **`2.0.2+18`**
6. **Synced** `assets/` from 2.14; merged branding SVGs from preserve
7. **Restored** Firebase native configs from preserve:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
8. **Kept** Android `applicationId` **`com.pt.sellspoint`** (unchanged in `android/app/build.gradle`)

## Sells Point patches (on 2.14 base)

### `lib/app_config.dart`

| Field | Value |
|-------|-------|
| `applicationName` | `Sells Point` |
| `hostUrl` | `https://admin.sellspoint.in` |
| `shareDomain` | `https://sellspoint.in` |

### `lib/utils/api.dart` — wallet / referral endpoints

- `check-reffercode`
- `apply-reffer`
- `refferal-history`
- `questions/Refferal`
- `questions/Wallet`
- `transaction-history`
- Param: `referredBy` → `"reffer_code"`

## Not done in R2 (by design)

- Routes / drawer / profile links for Status, Referral, Wallet
- Adapting legacy extras to 2.14 theme imports (`ui/theme/app_theme.dart` vs `ui/theme/theme.dart`)
- `register_cubits.dart` — referral/wallet cubits not registered yet
- iOS/Android Gradle full sync from 2.14 (only Firebase configs restored)
- `flutter pub get` / build (Flutter SDK not on this machine PATH)

## Expected compile errors until R4

Preserved modules still use **hybrid-era imports**, for example:

- `lib/ui/screens/referral_program/referral_program_screen.dart` → `ui/theme/theme.dart`
- Referral/wallet cubits may reference hybrid API helpers

Status module is partially aligned (uses `app/routes.dart`) but routes are not registered.

**Do not run hybrid Phase 71+** on this branch.

## Local next steps

```bash
cd "/Users/amityadav/Projects/Sells Point/sellspoint"
flutter pub get
flutter analyze   # expect errors until R4
```

## Rebase track

| Phase | Status |
|-------|--------|
| R1 | Done — backup tag, branch, preserve bundle |
| **R2** | **Done** — 2.14 base + restore + config/API patches |
| R3 | Pending — lock branding, native IDs, assets QA |
| R4 | Pending — wire Status / Referral / Wallet into 2.14 nav |
| R5 | Pending — build + admin API smoke |
| R6–R8 | Pending — full QA, release |

**Prerequisite for API testing:** Admin live + `php artisan migrate` (reels, home config, wallet endpoints).
