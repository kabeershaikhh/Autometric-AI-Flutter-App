import 'package:autometric_ai/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AutoMetricAIApp());
}

class AutoMetricAIApp extends StatelessWidget {
  const AutoMetricAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoMetric AI',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
        ),
      ),
      home: const AuthGate(),
    );
  }
}