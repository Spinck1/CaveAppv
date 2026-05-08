import 'package:flutter/services.dart';

class OrientationManager {
  /// Portrait moduna kısıtla (varsayılan)
  static Future<void> setPortraitOnly() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Tüm yönleri etkinleştir (harita vb. için)
  static Future<void> setAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Landscape moduna geç
  static Future<void> setLandscapeOnly() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
