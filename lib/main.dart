import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Import Firebase
import 'app.dart';
import 'env/env.dart';  // Import your environment variables
void main() async {
  // Ensure that Flutter binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the values from env.dart
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Env.firebaseApiKey,
      authDomain: Env.firebaseAuthDomain,
      projectId: Env.firebaseProjectId,
      storageBucket: Env.firebaseStorageBucket,
      messagingSenderId: Env.firebaseMessagingSenderId,
      appId: Env.firebaseAppId,
      measurementId: Env.firebaseMeasurementId,
    ),
  );

  runApp(const AdminPanelApp());  // Now you can run your app after Firebase is initialized
}
