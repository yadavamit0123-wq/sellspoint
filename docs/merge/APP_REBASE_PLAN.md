# App rebase plan — 2.14 base + Sells Point extras

| Phase | Status | Work |
|-------|--------|------|
| **R1** | Done | Backup tag, branch, preserve bundle |
| **R2** | Done | 2.14 source → base `lib/`, pubspec/native sync — see [APP_REBASE_R2.md](./APP_REBASE_R2.md) |
| **R3** | Done | Lock settings, Firebase, assets, `com.pt.sellspoint` — see [APP_REBASE_R3.md](./APP_REBASE_R3.md) |
| **R4** | Done | Wire Status, Referral, Wallet into 2.14 nav/routes — see [APP_REBASE_R4.md](./APP_REBASE_R4.md) |
| **R5** | Done | Build + admin API smoke — see [APP_REBASE_R5.md](./APP_REBASE_R5.md) |
| **R6** | Done | Full QA checklist + referral signup wiring — see [APP_REBASE_R6.md](./APP_REBASE_R6.md) |
| **R7–R8** | Pending | Release build + Play Store |

**Prerequisite:** Admin live + `php artisan migrate` for reels/home API tests.

**Do not continue** hybrid Phase 71+ on this branch — rebase track only.
