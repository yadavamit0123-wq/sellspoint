package com.pt.sellspoint

import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.pt.sellspoint/meta_sdk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "configure" -> {
                        val appId = call.argument<String>("appId")
                        val clientToken = call.argument<String>("clientToken")

                        if (appId.isNullOrBlank() || clientToken.isNullOrBlank()) {
                            result.error(
                                "INVALID_ARGUMENT",
                                "appId and clientToken are required",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        try {
                            FacebookSdk.setApplicationId(appId)
                            FacebookSdk.setClientToken(clientToken)
                            FacebookSdk.sdkInitialize(applicationContext)
                            FacebookSdk.fullyInitialize()
                            AppEventsLogger.activateApp(application)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("META_SDK_ERROR", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
