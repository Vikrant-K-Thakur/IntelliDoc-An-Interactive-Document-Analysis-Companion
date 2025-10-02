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
import 'package:docuverse/screens/main_container.dart';
import 'package:docuverse/screens/ai_document_interaction.dart';
import 'package:docuverse/screens/collaboration_sharing.dart';
import 'package:docuverse/screens/edit_profile.dart';
import 'package:docuverse/screens/folder_view.dart';
import 'package:docuverse/constants/app_constants.dart';
import 'package:docuverse/models/folder_model.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
    AppConstants.loginRoute: (context) => const LoginScreen(),
    AppConstants.registerRoute: (context) => const RegisterScreen(),
    AppConstants.forgetPasswordRoute: (context) => const ForgetPasswordScreen(),
    AppConstants.homeRoute: (context) => const MainContainer(initialIndex: 0),
    AppConstants.documentsRoute: (context) => const MainContainer(initialIndex: 1),
    AppConstants.studyToolsRoute: (context) => const MainContainer(initialIndex: 2),
    AppConstants.personalSpaceRoute: (context) => const MainContainer(initialIndex: 3),
    AppConstants.aiDocumentRoute: (context) => const AIDocumentInteractionScreen(),
    AppConstants.collaborationRoute: (context) => const CollaborationSharingScreen(),
    '/edit-profile': (context) => const EditProfileScreen(),
    '/folder-view': (context) => FolderViewScreen(
        folder: FolderModel(
          id: 'default',
          name: 'Folder',
          createdAt: DateTime.now(),
        ),
      ),
  };
}