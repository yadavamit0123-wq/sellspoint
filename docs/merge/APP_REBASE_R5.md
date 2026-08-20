# App rebase R5 — build check + admin API smoke

**Branch:** `rebase/eclassify-2.14-base`  
**Date:** 2026-08-19  
**Status:** Done (API smoke); build pending local Flutter SDK

## Goal

Verify the rebase app can talk to production admin APIs and provide a repeatable build/analyze path before R6 full QA.

## Scripts added

| Script | Purpose |
|--------|---------|
| `scripts/smoke_admin_api.py` | HTTP smoke against `https://admin.sellspoint.in/api/` |
| `scripts/r5_build_check.sh` | `flutter pub get`, `analyze`, debug APK |

```bash
python3 scripts/smoke_admin_api.py
./scripts/r5_build_check.sh   # requires Flutter 3.8+ on PATH
```

## Admin API smoke (2026-08-19)

Target: `https://admin.sellspoint.in/api/`

### PASS — live today

| Endpoint | Notes |
|----------|-------|
| `get-system-settings` | 200, settings load |
| `get-languages?language_code=en` | 200 (requires `language_code` query) |
| `get-categories` | 200 |
| `get-slider` | 200 |
| `get-featured-section` | 200 — powers home + status strip |
| `faq` | 200 |
| `questions/Refferal` | 200 — referral FAQ tab |
| `questions/Wallet` | 200 — wallet FAQ tab |
| `blogs` | 200 |
| `refferal-history` | 401 without JWT — route exists |
| `transaction-history` | 401 without JWT — route exists |
| `check-reffercode/TESTCODE` | 200 — route exists; returns “Invalid Reffer code” for dummy code |

### SKIP — needs admin 2.14 deploy + `php artisan migrate`

| Endpoint | HTTP | Impact on app |
|----------|------|----------------|
| `get-home-screen` | 404 | 2.14 configurable home blocks |
| `get-reels` | 404 | Reels tab / video ads |
| `get-popular-categories` | 404 | Popular categories widget |

**Blocker:** Deploy admin merge zip from `admin.sellspoint.in/sellspoint-admin-2.14-deploy-*.zip` before full 2.14 app QA.

### App ↔ API notes

- Referral check route is **path param**: `check-reffercode/{code}` (documented in `lib/utils/api.dart`).
- Wallet/referral history require authenticated user JWT (401 without login is expected).
- Status strip uses `get-featured-section` (works on live admin).

## Flutter build

Flutter SDK was **not available** in the agent environment (`flutter` not on PATH).

Run locally on a machine with Flutter **≥ 3.8** (matches `pubspec.yaml`):

```bash
cd "/Users/amityadav/Projects/Sells Point/sellspoint"
./scripts/r5_build_check.sh
```

Expected: `flutter analyze` clean or only pre-existing infos; debug APK builds.

## Manual device smoke (after build)

1. Splash → login → home loads categories/slider  
2. Profile → **My Wallet** / **Referral Program** (FAQs load without login; history needs login)  
3. Home status strip (if featured listings have gallery images)  
4. After admin deploy: reels tab, home configuration blocks  

## Rebase track

| Phase | Status |
|-------|--------|
| R1–R4 | Done |
| **R5** | **Done** (API smoke + scripts; local build on your machine) |
| R6 | Next — full QA (pay, reels, referral) after admin migrate |
