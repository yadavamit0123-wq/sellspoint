Website Seller Slug Links — Patch
===================================
Extract over sellspoint.in root, then:

  sudo -u www npm run build
  sudo -u www pm2 restart sellspoint

Files:
- components/PagesComponent/AdDetails/SellerDetailCard.jsx
- components/PagesComponent/Reels/ReelPlayer.jsx
- utils/seller.js
