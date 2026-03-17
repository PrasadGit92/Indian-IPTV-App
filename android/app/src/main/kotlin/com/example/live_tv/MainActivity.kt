package com.nk.live_tv

import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val pipChannel = "com.nk.live_tv/pip"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannel)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "enterPipMode" -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))
                .build()
              val entered = enterPictureInPictureMode(params)
              result.success(entered)
            } else {
              result.success(false)
            }
          }
          else -> result.notImplemented()
        }
      }
  }
}
