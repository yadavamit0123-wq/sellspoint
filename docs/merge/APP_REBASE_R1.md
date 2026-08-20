# App rebase — R1 complete (backup + preserve)

**Date:** 2026-08-19  
**Goal:** 2.14 app as base; keep Sells Point extras only.

## Done (R1)

### Git
- **Tag:** `backup-hybrid-phase70` — hybrid merge Phase 0–70 on `upgrade/eclassify-2.14`
- **Branch:** `rebase/eclassify-2.14-base` (active)

### Preserve bundle
`docs/merge/rebase_preserve/`

| Item | Purpose |
|------|---------|
| `lib/settings.dart` | API URL, app name, package, share text |
| `lib/firebase_options.dart` | Firebase |
| `lib/sells_point_modules.dart` | Module map |
| `lib/status/` | Status stories |
| `lib/ui/screens/referral_program/` | Referral UI |
| `lib/ui/screens/my_wallet/` + `data/cubits/my_wallet/` | Wallet |
| `lib/data/cubits/referral/` | Referral cubits |
| `lib/api.hybrid-reference.dart` | Sells Point API paths (`check-reffercode`, etc.) |
| `android/google-services.json`, `ios/GoogleService-Info.plist` | Native Firebase |
| `assets/svg`, `assets/image`, branding | Logos |
| `SOURCE_2.14_PATH.txt` | 2.14 Flutter source path |

### Paths
- **Live app:** `/Users/amityadav/Projects/Sells Point/sellspoint`
- **2.14 source (R2):** `/Users/amityadav/Projects/Sells Point/sellspoint new /eClassify-App-SourceCode-2.14.0`

## Next — R2 (approve to start)

1. Copy 2.14 `lib/` (+ required `pubspec`, android/ios deltas) as new base
2. Restore preserve files from `rebase_preserve/`
3. Do **not** change `settings.dart` URLs / Firebase / package id

## Rollback

```bash
git checkout upgrade/eclassify-2.14
# or reset to tag backup-hybrid-phase70
```
