Sells Point Admin (eClassify 2.14 merge) — SERVER DEPLOY
======================================================

BEFORE UPLOAD
-------------
1. Full MySQL backup (mandatory).
2. Maintenance mode optional.

DO NOT OVERWRITE ON SERVER
--------------------------
- .env (keep production keys; compare with .env.example for NEW keys only)
- storage/app/ (user uploads, images)
- public/storage symlink + uploaded media if separate

EXTRACT ZIP
-----------
Extract over admin root (e.g. admin.sellspoint.in). Merge/replace code files; keep server .env + storage uploads.

ON SERVER (PHP 8.1+, extensions: curl, openssl, zip)
-----------------------------------------------------
  composer install --no-dev --optimize-autoloader
  php artisan migrate
  php artisan db:seed --class=SystemUpgradeSeeder
  # Admin → Roles → grant new permissions to Super Admin
  php artisan config:clear
  php artisan cache:clear
  php artisan view:clear
  php artisan route:clear

NEVER run: migrate:fresh / migrate:refresh on live data.

SELLS POINT PRESERVED IN THIS BUILD
-----------------------------------
- ReferralService, SellsPointReferralApiController, wallet signup (AuthApiController)
- Q&A admin (quetion-answer), /refer/{id}, refer.blade.php

SMOKE TEST
----------
Admin login, packages, items, Q&A, settings (reels/Gemini if used).
API: check-reffercode, get-reels, user-signup.

BULK IMPORT (one-time on server after countries are imported)
-------------------------------------------------------------
  /www/server/php/82/bin/php artisan sellspoint:import-currencies
  /www/server/php/82/bin/php artisan sellspoint:import-languages

Run import-currencies only after Admin → Countries → Import Countries.
Language JSON files copy English templates; translate later in Admin → Languages.

Docs: docs/merge/STAGING_DEPLOY_CHECKLIST.md
