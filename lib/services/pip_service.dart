import 'package:flutter/services.dart';

class PipService {
  static const MethodChannel _channel =
      MethodChannel('com.nk.live_tv/pip');

  /// Attempts to enter Android Picture-in-Picture mode.
  ///
  /// Returns true if the platform successfully entered PiP mode.
  static Future<bool> enterPictureInPictureMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('enterPipMode');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
