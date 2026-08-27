# Sells Point — Server Deploy Guide (16 Points Update)
**Date:** 27 Aug 2026

---

## Kya deploy karna hai (Summary)

| # | Kahan | Kya | Server pe? |
|---|--------|-----|------------|
| 1 | **Admin** (`admin.sellspoint.in`) | Bulk currency + language import commands | ✅ Haan |
| 2 | **Website** (`sellspoint.in`) | UI fixes (verified, seller hide, reels, refer, location, notifications) | ✅ Haan |
| 3 | **Mobile App** | Saari 16-point changes | ❌ Server nahi — **naya APK/AAB** Play Store / direct install |

---

## ZIP files (is folder me)

| ZIP | Use |
|-----|-----|
| `1-admin-deploy.zip` | Extract → `admin.sellspoint.in` root |
| `2-website-deploy.zip` | Extract → `sellspoint.in` (website) root |
| `3-app-source-for-apk.zip` | Sirf reference — isse **APK build** karo (server pe upload nahi) |

---

## STEP 0 — Pehle (sab ke liye)

1. **Full MySQL backup** lo (phpMyAdmin ya `mysqldump`)
2. Optional: maintenance mode ON

---

## STEP 1 — Admin deploy (`admin.sellspoint.in`)

### Upload
1. `1-admin-deploy.zip` upload karo admin panel root pe
2. Extract karo — files overwrite hongi:
   - `app/Console/Commands/ImportCurrenciesFromWorld.php`
   - `app/Console/Commands/ImportWorldLanguages.php`
   - `app/Data/WorldLanguages.php`

### ⚠️ Mat overwrite karo
- `.env`
- `storage/app/` (uploads)
- `public/storage`

### Server commands (SSH)
```bash
cd /www/wwwroot/admin.sellspoint.in   # apna actual path

/www/server/php/82/bin/php artisan config:clear
/www/server/php/82/bin/php artisan cache:clear
/www/server/php/82/bin/php artisan route:clear
```

### Bulk import (ek baar — optional lekin recommended)
Pehle **Admin → Countries → Import Countries** se countries import karo, phir:

```bash
/www/server/php/82/bin/php artisan sellspoint:import-currencies
/www/server/php/82/bin/php artisan sellspoint:import-languages
```

Languages English template copy karega — baad me Admin → Languages se translate kar sakte ho.

---

## STEP 2 — Website deploy (`sellspoint.in`)

### Upload
1. `2-website-deploy.zip` upload karo website root pe
2. Extract — folder structure same rahegi (`components/`, `redux/`, `app/`)

### ⚠️ Mat overwrite karo
- `.env` (production keys)
- `.well-known/`, `app-ads.txt` (agar custom hain)

### Server commands (SSH — Node site)
```bash
cd /www/wwwroot/sellspoint.in   # apna actual path

npm install
npm run build

# PM2 / panel se restart (example):
# pm2 restart sellspoint-web
# ya: npm start  (NODE_PORT=8006)
```

### Website me kya fix hua
- Verified badge color `#05a61d`
- Seller email/mobile hidden
- Video reels — Like + Chat visible
- Refer & Earn page + menu enable
- Location modal — pehle country list
- Notification me clickable URLs

---

## STEP 3 — Mobile App (APK — server pe NAHI)

App changes **server pe upload nahi hote**. Naya build chahiye:

### Option A — Local / CI build
```bash
cd sellspoint
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Option B — GitHub Actions (agar setup hai)
`docs/merge/GITHUB_ANDROID_BUILD.md` dekho

### App me kya fix hua (zip `3-app-source-for-apk.zip` me files)
- Verified badge `#05a61d`
- Status strip + featured flow
- Home pe Add Listing (tricolor) status se pehle
- My Wallet / Referral Program labels
- Edit profile referral code
- Footer Video Ad golden icon
- Popular Category "More"
- Notification clickable links
- Status–category gap kam
- Seller contact hidden

APK users ko Play Store update ya direct APK se do.

---

## Deploy order (recommended)

```
1. MySQL backup
2. Admin zip upload + artisan clear cache
3. (Optional) import-currencies + import-languages
4. Website zip upload + npm run build + restart
5. Mobile APK build + distribute
6. Smoke test (neeche)
```

---

## Smoke test checklist

### Admin
- [ ] Login
- [ ] Settings load
- [ ] Countries list
- [ ] `php artisan sellspoint:import-currencies` (agar chalaya)

### Website
- [ ] Home load
- [ ] Ad details — verified green badge, seller email hidden
- [ ] Video reel — Like + Chat dikhe
- [ ] Profile → Refer & Earn (agar admin me enabled)
- [ ] Location — country list pehle
- [ ] Notification me link click

### Mobile App
- [ ] Home — status, add listing button, categories More
- [ ] Footer Video Ad icon
- [ ] Profile — My Wallet, Referral Program
- [ ] Edit profile — referral code
- [ ] Verified badge green

---

## Server paths (aapke live setup ke hisaab se adjust karo)

| Service | Domain | PHP/Node |
|---------|--------|----------|
| Admin + API | admin.sellspoint.in | PHP 8.2 FPM: `/www/server/php/82/bin/php` |
| Website | sellspoint.in | Node 20+, port ~8006 |

---

## Help / issues

- Login fail → `AuthApiController.php` + Firebase authorized domains check
- Website blank after deploy → `npm run build` logs dekho
- Artisan fail → PHP 8.2 path use karo, 8.1 nahi
- App changes live nahi → naya APK install karna zaroori hai
