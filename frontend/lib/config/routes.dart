// config/routes.dart
import 'package:flutter/material.dart';
import 'package:docuverse/screens/login.dart';
import 'package:docuverse/screens/register.dart';
import 'package:docuverse/screens/forget_password.dart';
import 'package:docuverse/screens/onboarding.dart';
import 'package:docuverse/screens/home.dart';
import 'package:docuverse/screens/documents.dart';
import 'package:docuverse/screens/study_tools.dart';
import 'package:docuverse/screens/personal_space.dart';
import 'package:docuverse/screens/ai_document_interaction.dart';
import 'package:docuverse/screens/collaboration_sharing.dart';
import 'package:docuverse/constants/app_constants.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
    AppConstants.loginRoute: (context) => const LoginScreen(),
    AppConstants.registerRoute: (context) => const RegisterScreen(),
    AppConstants.forgetPasswordRoute: (context) => const ForgetPasswordScreen(),
    AppConstants.homeRoute: (context) => const HomeScreen(),
    AppConstants.documentsRoute: (context) => const DocumentsScreen(),
    AppConstants.studyToolsRoute: (context) => const StudyToolsScreen(),
    AppConstants.personalSpaceRoute: (context) => const PersonalSpaceScreen(),
    AppConstants.aiDocumentRoute: (context) => const AIDocumentInteractionScreen(),
    AppConstants.collaborationRoute: (context) => const CollaborationSharingScreen(),
  };
}