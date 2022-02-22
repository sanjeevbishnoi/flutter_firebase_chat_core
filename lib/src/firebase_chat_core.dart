import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_chat_core/src/firestore_functions.dart';
import 'package:flutter_firebase_chat_core/src/realtime_functions.dart';
import 'package:flutter_firebase_chat_core/src/utils/firebase_product_type.dart';
import 'utils/firebase_chat_core_config.dart';

/// Provides access to Firebase chat data. Singleton, use
/// FirebaseChatCore.instance to aceess methods.
class FirebaseChatCore {
  FirebaseChatCore._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      firebaseUser = user;
    });
  }

  /// Current logged in user in Firebase. Does not update automatically.
  /// Use [FirebaseAuth.authStateChanges] to listen to the state changes.
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  /// Config to set custom names for rooms and users collections. Also
  /// see [FirebaseChatCoreConfig].
  FirebaseChatCoreConfig config = const FirebaseChatCoreConfig(
    null,
    FirebaseProductType.fireStore,
    'rooms',
    'users',
  );

  /// Singleton instance
  static final FirebaseChatCore instance =
      FirebaseChatCore._privateConstructor();

  /// Gets proper [FirebaseFirestore] instance
  FirebaseFirestore getFirebaseFirestore() {
    return config.firebaseAppName != null
        ? FirebaseFirestore.instanceFor(
            app: Firebase.app(config.firebaseAppName!),
          )
        : FirebaseFirestore.instance;
  }

  /// Gets proper [FirebaseRealtime database] instance
  FirebaseDatabase getFirebaseRealTimeDatabase() {
    return config.firebaseAppName != null
        ? FirebaseDatabase.instanceFor(
            app: Firebase.app(config.firebaseAppName!),
          )
        : FirebaseDatabase.instance;
  }

  /// Sets custom config to change default names for rooms
  /// and users collections. Also see [FirebaseChatCoreConfig].
  void setConfig(FirebaseChatCoreConfig firebaseChatCoreConfig) {
    config = firebaseChatCoreConfig;
  }

  FireStoreFunctions get firestoreFunctions {
    return FireStoreFunctions(
        config: config,
        firebaseUser: firebaseUser,
        firebaseFirestore: getFirebaseFirestore());
  }

  RealTimeFunctions get realtimeFunctions {
    return RealTimeFunctions(
        config: config,
        firebaseUser: firebaseUser,
        firebaseRealTime: getFirebaseRealTimeDatabase());
  }
}
