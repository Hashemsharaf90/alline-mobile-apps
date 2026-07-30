package com.activeitzone.delivery_app

import android.os.Bundle
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (FirebaseApp.getApps(this).isEmpty()) {
            val options = FirebaseOptions.Builder()
                .setApiKey("AIzaSyBtKZiFUjtspJKvoYRq8xPMQjLajRnkhos")
                .setApplicationId("1:974823733639:android:ae79f0632e6c63e8c8fb22")
                .setProjectId("thgi4-1da1f")
                .setGcmSenderId("974823733639")
                .setStorageBucket("thgi4-1da1f.firebasestorage.app")
                .build()
            FirebaseApp.initializeApp(this, options)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "allin_delivery/notifications"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getFcmToken" -> {
                    FirebaseMessaging.getInstance().token
                        .addOnSuccessListener { token -> result.success(token) }
                        .addOnFailureListener { exception ->
                            result.error("FCM_TOKEN_ERROR", exception.message, null)
                        }
                }
                else -> result.notImplemented()
            }
        }
    }
}
