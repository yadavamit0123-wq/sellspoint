Sells Point Website — Server Deploy (Seller Slug + UI)
======================================================
Date: 31 Aug 2026

WHAT THIS ZIP CONTAINS
----------------------
- Seller profile page: /[lang]/seller/[slug]  (e.g. /en/seller/saaho-mori-1277)
- Slug links on ad details + reels
- iOS universal links (apple-app-site-association)
- Refer & earn, profile, notifications, location fixes (if not already live)

FILES
-----
app/[lang]/seller/[slug]/page.jsx
app/[lang]/(profile)/refer-and-earn/page.jsx
components/PagesComponent/Seller/SellerProfile.jsx
components/PagesComponent/Seller/SellerDetailCard.jsx
components/PagesComponent/AdDetails/SellerDetailCard.jsx
components/PagesComponent/Reels/ReelPlayer.jsx
components/PagesComponent/ReferAndEarn/ReferAndEarn.jsx
components/PagesComponent/Notifications/Notifications.jsx
components/Profile/Profile.jsx
components/Profile/ProfileSidebar.jsx
components/Common/LinkText.jsx
components/Location/LocationModal.jsx
redux/reducer/settingSlice.js
utils/seller.js
.well-known/apple-app-site-association

BEFORE UPLOAD
-------------
1. Backup current website folder (optional but recommended)

DO NOT OVERWRITE
----------------
- .env (production keys)
- Custom .well-known files if you edited them manually (merge paths instead)

MANUAL STEP — utils/api.js
--------------------------
If getSellerApi is not in your api.js, add:

  export const getSellerApi = {
    getSeller: (params) => api.get("get-seller", { params }),
  };

AASA FILE
---------
Edit .well-known/apple-app-site-association:
Replace TEAMID with your Apple Developer Team ID.

EXTRACT
-------
Extract over website root, e.g. /www/wwwroot/sellspoint.in

ON SERVER (SSH)
---------------
cd /www/wwwroot/sellspoint.in

npm install
npm run build
pm2 restart all

SMOKE TEST
----------
1. https://sellspoint.in/en/seller/saaho-mori-1277  → seller page
2. https://sellspoint.in/en/seller/1277               → old numeric URL still works
3. Ad details → seller link uses slug (after admin deploy + migration)
4. Share seller profile from app → opens web or app
