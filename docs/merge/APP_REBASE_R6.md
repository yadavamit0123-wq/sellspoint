# App rebase R6 — full QA checklist (pay, reels, referral)

**Branch:** `rebase/eclassify-2.14-base`  
**Date:** 2026-08-19  
**Status:** Done (checklist + referral signup wiring); device QA on your machine

## Code changes in R6

| Change | Purpose |
|--------|---------|
| `lib/data/repositories/referral_repository.dart` | `checkReferralCode`, `applyPendingReferral` |
| `lib/data/repositories/auth_repository.dart` | Apply pending referral after `user-signup` |
| `lib/utils/hive_keys.dart` + `hive_utils.dart` | Persist optional referral code until signup completes |
| `lib/ui/screens/auth/sign_up/signup_screen.dart` | Optional referral code field (phone signup) |

Flow: user enters code → stored in Hive → after successful signup/login API → `POST apply-reffer` with `user_id` + `reffer_code`.

## Prerequisites

- [ ] Admin 2.14 deployed + `php artisan migrate` (for reels + home config)
- [ ] `./scripts/r5_build_check.sh` passes locally
- [ ] Test account + payment sandbox keys enabled in admin

## Automated checks

```bash
python3 scripts/smoke_admin_api.py
./scripts/r5_build_check.sh
```

## QA matrix

### A — Auth & referral

| # | Test | Expected | Pass |
|---|------|----------|------|
| A1 | Phone signup without referral code | Account created; wallet signup bonus from admin | ☐ |
| A2 | Phone signup with valid referral code | `apply-reffer` succeeds; referrer reward (admin rules) | ☐ |
| A3 | Phone signup with invalid code | Signup still works; apply fails silently / no crash | ☐ |
| A4 | Profile → Referral Program → Refer tab | Shows user's `reffer_id`; copy + WhatsApp share | ☐ |
| A5 | Profile → Referral → My Referrals | List loads when logged in | ☐ |
| A6 | Referral FAQ tab | Loads from `questions/Refferal` | ☐ |
| A7 | Complete profile → referral field | Updates via profile API if supported | ☐ |
| A8 | Invite link `https://sellspoint.in/refer` | Opens web refer page (website deploy) | ☐ |

### B — Wallet

| # | Test | Expected | Pass |
|---|------|----------|------|
| B1 | Profile → My Wallet | Balance from user `wallet` field | ☐ |
| B2 | Transactions tab | `transaction-history` list | ☐ |
| B3 | FAQ tab | `questions/Wallet` | ☐ |

### C — Payments (subscription / packages)

| # | Test | Expected | Pass |
|---|------|----------|------|
| C1 | Profile → Subscription | Package list loads | ☐ |
| C2 | Select plan → payment sheet | Enabled gateways from admin (Stripe/Razorpay/PhonePe/etc.) | ☐ |
| C3 | Complete test payment | Active plan shown; receipt/history updated | ☐ |
| C4 | Bank transfer flow (if enabled) | Upload proof; status updates | ☐ |
| C5 | In-app purchase (if enabled) | Store purchase completes | ☐ |

### D — Reels & video (after admin 2.14 live)

| # | Test | Expected | Pass |
|---|------|----------|------|
| D1 | Reels tab loads | `get-reels` returns feed | ☐ |
| D2 | Like / scroll reels | No crash; pagination works | ☐ |
| D3 | Post video ad (package gate) | Subscription check; upload queue | ☐ |
| D4 | Reel deep link / notification | Opens reels with `item_id` / `reel_id` | ☐ |

### E — Home & status

| # | Test | Expected | Pass |
|---|------|----------|------|
| E1 | Home loads | Slider, categories, featured sections | ☐ |
| E2 | Status strip | Shows when featured items have gallery images | ☐ |
| E3 | Tap status story | Full-screen viewer; ad details link | ☐ |
| E4 | Home config blocks (post-migrate) | Order matches admin `get-home-screen` | ☐ |

### F — Core 2.14 regression

| # | Test | Expected | Pass |
|---|------|----------|------|
| F1 | Login / logout | JWT + FCM | ☐ |
| F2 | Post ad wizard | Category → details → location → publish | ☐ |
| F3 | Chat / offers | Send message; offer flow | ☐ |
| F4 | Deep link `sellspoint://sellspoint.in/...` | Opens ad details | ☐ |
| F5 | Dark mode + language | Profile toggles | ☐ |

## Known blockers (2026-08-19)

| Item | Status |
|------|--------|
| `get-home-screen`, `get-reels`, `get-popular-categories` | 404 on live admin — skip until deploy |
| Reels QA (section D) | Blocked until admin migrate |
| Flutter build in agent env | Run `./scripts/r5_build_check.sh` locally |

## Sign-off

| Role | Name | Date | Notes |
|------|------|------|-------|
| Dev build | | | `flutter analyze` / APK |
| Referral + wallet | | | Sections A + B |
| Payments | | | Section C |
| Reels | | | Section D (post-admin) |
| Release go | | | → R7 |

## Rebase track

| Phase | Status |
|-------|--------|
| R1–R5 | Done |
| **R6** | **Done** (checklist + referral apply wiring) |
| R7 | Next — release build |
