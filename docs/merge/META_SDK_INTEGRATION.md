# Meta SDK (Facebook App Events) Integration

Admin-driven Meta SDK for Sells Point install/ad attribution — same pattern as AdMob settings.

## Admin panel

**Path:** Settings → Meta SDK (`/settings/meta-sdk`)

| Setting key | Purpose |
|-------------|---------|
| `meta_sdk_enabled` | Master on/off |
| `facebook_app_id` | Meta App ID |
| `facebook_client_token` | Meta Client Token |
| `meta_test_mode` | SDK debug logging |
| `meta_log_activate_app` | Log app open / activate |
| `meta_log_registration` | Log signup completion |
| `meta_log_purchase` | Log subscription purchase |

These keys are returned in `GET /api/get-system-settings` (mobile app reads them on splash).

**After saving in admin:** clear settings cache if needed (Laravel `CachingService`).

## Mobile app

- Package: `facebook_app_events`
- Service: `lib/utils/meta_sdk_service.dart`
- Init: after `SystemSettingsCubit.getSystemSettings()` succeeds
- Native bridge: `com.pt.sellspoint/meta_sdk` sets App ID + Client Token at runtime (admin values)

### Events logged

| Event | When |
|-------|------|
| Activate app | App launch (if enabled) |
| Complete registration | Signup success |
| Purchase + Subscribe | Stripe, Razorpay, PhonePe, web gateways, IAP |

### Native placeholders

Android `strings.xml` and iOS `Info.plist` use placeholder `0` / `placeholder`. Real credentials come from admin via API at runtime — **no app update needed** when IDs change (only enable/disable + event toggles).

## Meta Business Manager setup

1. Create app at [developers.facebook.com](https://developers.facebook.com)
2. Add **Android** package `com.pt.sellspoint` + release key hash
3. Add **iOS** bundle ID + App Store ID
4. Copy **App ID** and **Client Token** into admin → Meta SDK
5. Enable Meta SDK + event toggles
6. Use **Events Manager → Test Events** (enable Test Mode in admin for verbose logs)

## Release checklist

- [ ] Admin Meta SDK page saved with real App ID + Client Token
- [ ] `flutter pub get` (adds `facebook_app_events`)
- [ ] Android release build (Facebook SDK via plugin)
- [ ] iOS: `pod install` after pub get
- [ ] iOS ATT string present (`NSUserTrackingUsageDescription`)
- [ ] Verify events in Meta Events Manager after test signup/purchase

## Not included

- Meta Ads Manager campaigns (configure separately)
- App Secret in client app (never ship)
- Facebook Login SDK
