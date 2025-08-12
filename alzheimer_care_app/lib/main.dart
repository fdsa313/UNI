import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/caregiver_password_screen.dart';
import 'screens/caregiver_mode_screen.dart';
import 'screens/quiz_settings_screen.dart';
import 'screens/medication_settings_screen.dart';
import 'screens/emergency_call_screen.dart';
import 'screens/app_termination_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/medication_screen.dart';
import 'screens/progress_report_screen.dart';
import 'screens/patient_management_screen.dart';
import 'screens/app_exit_video_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  
  try {
    await Supabase.initialize(
      url: 'https://yfimuntjanrhhsxogmnw.supabase.co',
      anonKey: 'sb_publishable_lYdNwinXWuWC_Z6iUXm2Mg_FOYoLnRq',
    );
    print('✅ Supabase 초기화 성공');
  } catch (e) {
    print('❌ Supabase 초기화 실패: $e');
  }
  
  runApp(const HaimerDinggerApp());
}

class HaimerDinggerApp extends StatelessWidget {
  const HaimerDinggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하이머딩거',
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
          return CaregiverPasswordScreen(userName: userName);
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
        '/progress-report': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userName = args is String ? args : null;
          return ProgressReportScreen(userName: userName);
        },
        '/patient-management': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userName = args is String ? args : null;
          return PatientManagementScreen(userName: userName);
        },
        '/app-exit-video': (context) => const AppExitVideoScreen(),

      },
    );
  }
}
