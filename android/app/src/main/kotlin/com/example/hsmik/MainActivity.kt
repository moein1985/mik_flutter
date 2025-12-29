package com.example.hsmik

import android.os.Build
import android.util.Log
import android.window.OnBackInvokedCallback
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.hsmik/back_button"
    private val TAG = "MainActivity"
    private var methodChannel: MethodChannel? = null
    private var shouldInterceptBack = true
    private var backCallback: OnBackInvokedCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "configureFlutterEngine: Setting up back button handler")
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "setInterceptBack" -> {
                    shouldInterceptBack = call.argument<Boolean>("intercept") ?: true
                    Log.d(TAG, "setInterceptBack: shouldInterceptBack = $shouldInterceptBack")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        
        // Setup back handler for Android 13+ (API 33+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setupBackHandlerApi33()
        }
    }

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun setupBackHandlerApi33() {
        Log.d(TAG, "Setting up OnBackInvokedCallback for API 33+")
        backCallback = OnBackInvokedCallback {
            Log.d(TAG, "OnBackInvokedCallback: shouldInterceptBack = $shouldInterceptBack")
            if (shouldInterceptBack) {
                Log.d(TAG, "OnBackInvokedCallback: Sending to Flutter")
                methodChannel?.invokeMethod("onBackPressed", null)
            } else {
                Log.d(TAG, "OnBackInvokedCallback: Finishing activity")
                finish()
            }
        }
        
        onBackInvokedDispatcher.registerOnBackInvokedCallback(
            android.window.OnBackInvokedDispatcher.PRIORITY_DEFAULT,
            backCallback!!
        )
        Log.d(TAG, "OnBackInvokedCallback registered successfully")
    }

    @Suppress("OVERRIDE_DEPRECATION")
    override fun onBackPressed() {
        Log.d(TAG, "onBackPressed (legacy): shouldInterceptBack = $shouldInterceptBack")
        if (shouldInterceptBack) {
            Log.d(TAG, "onBackPressed: Sending to Flutter")
            methodChannel?.invokeMethod("onBackPressed", null)
        } else {
            Log.d(TAG, "onBackPressed: Calling super.onBackPressed()")
            super.onBackPressed()
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: Cleaning up")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && backCallback != null) {
            onBackInvokedDispatcher.unregisterOnBackInvokedCallback(backCallback!!)
        }
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        super.onDestroy()
    }
}
