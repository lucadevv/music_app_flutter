import 'dart:io';

import 'package:flutter/foundation.dart';

enum AppPlatform {
  android,
  ios,
  web,
  unknown;

  String get value {
    switch (this) {
      case AppPlatform.android:
        return 'android';
      case AppPlatform.ios:
        return 'ios';
      case AppPlatform.web:
        return 'web';
      case AppPlatform.unknown:
        return 'unknow';
    }
  }

  static AppPlatform get current {
    if (kIsWeb) {
      return AppPlatform.web;
    } else if (Platform.isAndroid) {
      return AppPlatform.android;
    } else if (Platform.isIOS) {
      return AppPlatform.ios;
    } else {
      return AppPlatform.unknown;
    }
  }
}
