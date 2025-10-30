<<<<<<< HEAD
// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:docuverse/config/app_config.dart';
import 'package:docuverse/core/routes.dart';
import 'package:docuverse/shared/constants/app_constants.dart';
=======
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:docuverse/constants/app_theme.dart';
import 'package:docuverse/routes.dart';
// import 'package:docuverse/screens/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
>>>>>>> 17955a8 (Updated project)
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DocuSenseAIApp());
}

class DocuSenseAIApp extends StatelessWidget {
  const DocuSenseAIApp({super.key});
=======
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const DocuVerseApp());
}

class DocuVerseApp extends StatelessWidget {
  const DocuVerseApp({super.key});
>>>>>>> 17955a8 (Updated project)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: AppConstants.appName,
      theme: AppConfig.theme,
      initialRoute: AppConstants.loginRoute,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
=======
      title: 'DocuVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('mr', ''),
      ],
      initialRoute: '/splash',
      routes: Routes.routes,
>>>>>>> 17955a8 (Updated project)
    );
  }
}