# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase / Google Play services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Meta / Facebook SDK
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Stripe / Razorpay and other payment SDKs
-keep class com.stripe.** { *; }
-keep class com.razorpay.** { *; }
-dontwarn com.stripe.**
-dontwarn com.razorpay.**

# Gson / reflection used by SDKs
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
