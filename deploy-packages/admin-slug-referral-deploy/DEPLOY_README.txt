Sells Point Admin — Server Deploy (Slug + Referral)
====================================================
Date: 31 Aug 2026

WHAT THIS ZIP CONTAINS
----------------------
- Seller profile slug (users.slug column + API)
- Referral restore (Level 1 = Rs 5, signup bonus fix)
- get-seller by id OR slug

FILES
-----
database/migrations/2026_08_29_120000_add_slug_to_users_table.php
app/Models/User.php
app/Services/HelperService.php
app/Services/ReferralService.php
app/Services/DefaultSettingService.php
app/Http/Controllers/Api/UserApiController.php
app/Http/Controllers/Api/ItemApiController.php
app/Http/Controllers/Api/AuthApiController.php
app/Http/Controllers/Api/SellsPointReferralApiController.php

BEFORE UPLOAD
-------------
1. Full MySQL backup (mandatory)

DO NOT OVERWRITE
----------------
- .env
- storage/app/ (uploads)
- public/storage

EXTRACT
-------
Extract over admin root, e.g. /www/wwwroot/admin.sellspoint.in

ON SERVER (SSH)
---------------
cd /www/wwwroot/admin.sellspoint.in

php artisan migrate
php artisan config:clear
php artisan cache:clear
php artisan route:clear

NEVER run: migrate:fresh / migrate:refresh on live data.

DB SETTINGS (verify in Admin or phpMyAdmin)
------------------------------------------
signup_bonus          = 10
reffer_level_income   = {"1":5}
refer_earn_enabled    = 1

SMOKE TEST
----------
1. GET /api/get-seller?slug=saaho-mori-1277  → seller data
2. GET /api/get-seller?id=1277               → still works
3. New user signup → wallet Rs 10
4. Referral apply → friend Rs 10, referrer Rs 5
