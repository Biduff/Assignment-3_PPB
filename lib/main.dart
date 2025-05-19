import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:test_firewall/screens/home.dart';
import 'package:test_firewall/screens/login.dart';
import 'package:test_firewall/screens/register.dart';
import 'package:test_firewall/screens/second_screen.dart';
import 'package:test_firewall/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Awesome Notifications
  await NotificationService.initializeNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Required for navigation from notifications
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combined App',
      navigatorKey: navigatorKey,
      initialRoute: 'login',
      routes: {
        'home': (context) => const HomeScreen(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'second': (context) => const SecondScreen(),
      },
    );
  }
}
