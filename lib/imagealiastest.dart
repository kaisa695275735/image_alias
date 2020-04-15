import 'dart:async';

import 'package:flutter/services.dart';

class Imagealiastest {
  static const MethodChannel _channel =
      const MethodChannel('imagealiastest');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> initialize() async {
//    TLog.debug("EngineImageTest create Controller");
    final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'create',
    );
    return response['textureId'];
  }
}
