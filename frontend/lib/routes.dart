import 'package:flutter/material.dart';
import 'package:docuverse/screens/auth/login_page.dart';
import 'package:docuverse/screens/auth/register_page.dart';
import 'package:docuverse/screens/auth/forgot_password_page.dart';
import 'package:docuverse/screens/splash_screen.dart';
import 'package:docuverse/screens/home_page.dart';
import 'package:docuverse/screens/document_upload_page.dart';
import 'package:docuverse/screens/document_viewer.dart';
import 'package:docuverse/screens/result_page.dart';
import 'package:docuverse/screens/profile_page.dart';
import 'package:docuverse/screens/settings_page.dart';
import 'package:docuverse/screens/smart_plan_page.dart';
import 'package:docuverse/screens/flashcards_page.dart';

class Routes {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/forgot-password': (context) => const ForgotPasswordPage(),
    '/home': (context) => const HomePage(),
    '/upload': (context) => const DocumentUploadPage(),
    '/viewer': (context) => const DocumentViewer(),
    '/result': (context) => const ResultPage(),
    '/profile': (context) => const ProfilePage(),
    '/settings': (context) => const SettingsPage(),
    '/study-plan': (context) => const SmartPlanPage(),
    '/flashcards': (context) => const FlashcardsPage(),
  };
}