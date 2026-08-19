# Firebase lock — Sells Point production

**Locked in R3.** Do not regenerate or overwrite without updating all rows below.

## Summary

Production uses **two Firebase projects** (inherited from live app):

| Layer | Android | iOS |
|-------|---------|-----|
| Gradle / native plist | **`sells-point`** | **`eclassify-wrteam`** |
| Flutter `firebase_options.dart` | **`eclassify-wrteam`** | **`eclassify-wrteam`** |
| Maps API key (AndroidManifest) | `AIzaSyA_usa-…` (eclassify-wrteam) | — |

This split was preserved from the live app. Unifying to a single project is a future ops task (FlutterFire CLI + new plists).

## File reference

| File | Project / package |
|------|-------------------|
| `android/app/google-services.json` | `project_id: sells-point`, `package_name: com.pt.sellspoint` |
| `ios/Runner/GoogleService-Info.plist` | `PROJECT_ID: eclassify-wrteam`, `BUNDLE_ID: com.pt.sellspoint` |
| `lib/firebase_options.dart` | Android + iOS → `eclassify-wrteam`, `iosBundleId: com.pt.sellspoint` |
| `ios/firebase_app_id_file.json` | `eclassify-wrteam` |

## Init rule (R3 fix)

`lib/app/app.dart` must call:

```dart
if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
```

Never call `Firebase.initializeApp()` without options on cold start.

## Package id (locked)

- Android: `com.pt.sellspoint` (`applicationId`, `namespace`, manifest)
- iOS: `com.pt.sellspoint` (`PRODUCT_BUNDLE_IDENTIFIER`)
