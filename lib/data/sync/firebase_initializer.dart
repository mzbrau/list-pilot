import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Lazily initializes Firebase when the user opens sync/premium settings.
class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _initialized = true;
  }

  static bool get isInitialized => _initialized || Firebase.apps.isNotEmpty;
}
