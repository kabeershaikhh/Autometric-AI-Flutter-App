import 'package:autometric_ai/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF)),
      ),
      home: const _AppStartup(),
    );
  }
}

class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      Future<void>.delayed(const Duration(milliseconds: 1800)),
    ]);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to start AutoMetric AI. Please try again.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      setState(() => _initialization = _initialize()),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const SplashPage();
      }
      return const AuthGate();
    },
  );
}
