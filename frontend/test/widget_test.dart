// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docuverse/main.dart';
<<<<<<< HEAD

void main() {
  testWidgets('App starts with onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const DocuSenseAIApp());

    // Verify that the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
=======
import 'package:docuverse/screens/splash_screen.dart';

void main() {
  testWidgets('App starts with splash screen and navigates to login', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const DocuVerseApp());

    // Verify that we have the splash screen
    expect(find.byType(SplashScreen), findsOneWidget);

    // Wait for the splash screen to complete (2 seconds in your actual code)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify login page elements without importing LoginPage
    expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Welcome to DocuVerse'), findsOneWidget);
>>>>>>> 17955a8 (Updated project)
  });
}
