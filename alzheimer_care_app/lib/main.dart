import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/caregiver_mode_screen.dart';
import 'screens/quiz_settings_screen.dart';
import 'screens/medication_settings_screen.dart';
import 'screens/emergency_call_screen.dart';
import 'screens/app_termination_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/medication_screen.dart';

void main() {
  runApp(const AlzheimerCareApp());
}

class AlzheimerCareApp extends StatelessWidget {
  const AlzheimerCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알츠하이머 케어',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFFFB74D),
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        fontFamily: 'NotoSansKR',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFB74D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userName = args is String ? args : null;
          return HomeScreen(userName: userName);
        },
        '/caregiver': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userName = args is String ? args : null;
          return CaregiverModeScreen(userName: userName);
        },
        '/quiz-settings': (context) => const QuizSettingsScreen(),
        '/medication-settings': (context) => const MedicationSettingsScreen(),
        '/emergency-call': (context) => const EmergencyCallScreen(),
        '/app-termination': (context) => const AppTerminationScreen(),
        '/settings': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userName = args is String ? args : null;
          return SettingsScreen(userName: userName);
        },
        '/quiz': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userName = args is String ? args : null;
          return QuizScreen(userName: userName);
        },
        '/medication': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userName = args is String ? args : null;
          return MedicationScreen(userName: userName);
        },
      },
    );
  }
}
