# App rebase R4 — Status, Referral, Wallet wired into 2.14 nav

**Branch:** `rebase/eclassify-2.14-base`  
**Date:** 2026-08-19  
**Status:** Done (local)

## Goal

Connect preserved Sells Point modules to the stock 2.14 shell: routes, profile menu, home status strip, and supporting models/constants.

## Routes (`lib/app/routes.dart`)

| Route | Screen |
|-------|--------|
| `/myWalletScreen` | `MyWalletScreen` |
| `/referralProgramScreen` | `ReferralProgramScreen` |
| `/statusStoriesViewer` | `StatusUserViewer` (args: `allUsers`, `initialUserIndex`) |

Gated by `SellsPointModules` flags.

## Profile menu (`profile_tab_screen.dart`)

Under **Subscription** section (auth required):

- **My Wallet** → `Routes.myWalletScreen`
- **Referral Program** → `Routes.referralProgramScreen`

Uses `AppIcons.wallet` / `AppIcons.gift` and translation keys `myWallet`, `referralProgram`.

## Home — Status stories

- New `lib/new_development/status/widgets/home_status_strip.dart`
- Inserted after search on home (`home_screen.dart`)
- Builds `StatusModel` list from `FeaturedSectionCubit` listing gallery images
- Renders existing `StatusWidget` → tap opens `statusStoriesViewer`

## Models & config

| Change | Purpose |
|--------|---------|
| `UserModel` + `wallet`, `referId`, `byReferId` | Admin wallet / referral fields |
| `lib/data/model/user_model.dart` | Export shim for legacy imports |
| `referral_history_model`, `wallet_transaction_model`, `faq_response` | Restored from hybrid backup |
| `blur_page_route.dart` | Wallet/referral screen transitions |
| `Constant` share fields | `inviteURL`, `shareappText`, `appName` from `AppSettings` |
| `AppConfig.enable*` flags | Mirror `SellsPointModules` |
| `RemoveGlow` in `ui_utils.dart` | Scroll behavior for wallet/referral screens |
| Referral screen | `gift.svg` asset, `referId` / `referralCode` fallback |

## Not in R4 (R5/R6)

- Signup referral code field / `apply-reffer` on register
- Deep link to `/refer` with pre-filled code
- Full compile/build verification (Flutter SDK not on CI machine)
- End-to-end API QA against migrated admin

## Local verify

```bash
cd "/Users/amityadav/Projects/Sells Point/sellspoint"
flutter pub get
flutter analyze
flutter run
```

Test: Profile → Wallet / Referral; Home status strip → story viewer.

## Rebase track

| Phase | Status |
|-------|--------|
| R1–R3 | Done |
| **R4** | **Done** |
| R5 | Next — build + admin API smoke |
