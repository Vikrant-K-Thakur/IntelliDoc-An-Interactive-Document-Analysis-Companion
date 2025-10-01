// screens/study_tools.dart
import 'package:flutter/material.dart';
import 'package:docuverse/services/auth_service.dart';
import 'package:docuverse/constants/app_constants.dart';
import 'package:docuverse/widgets/bottom_navigation.dart';

class StudyToolsScreen extends StatefulWidget {
  const StudyToolsScreen({super.key});

  @override
  State<StudyToolsScreen> createState() => _StudyToolsScreenState();
}

class _StudyToolsScreenState extends State<StudyToolsScreen> {
  // Marked as final because we never change it
  final int _currentIndex = 2;

  void _checkAuthAndNavigate(String route) {
    if (!AuthService.isLoggedIn) {
      _showLoginDialog();
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login first to preview the app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Tools'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Study Toolkit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enhance your learning with intelligent features.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildToolCard(
              'Flashcards',
              'Create, review, and master concepts with AI-powered flashcards.',
              onTap: () => _checkAuthAndNavigate('/flashcards'),
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              'Quiz Generator',
              'Generate quizzes from your documents in various formats.',
              onTap: () => _checkAuthAndNavigate('/quiz'),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 24),
            _buildToolCard(
              'Study Plan',
              'Design personalized study plans with intelligent scheduling.',
              onTap: () => _checkAuthAndNavigate('/study-plan'),
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              'AI Tutor',
              'Get instant help and explanations from your AI study companion.',
              onTap: () => _checkAuthAndNavigate('/ai-tutor'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        context: context,
      ),
    );
  }

  Widget _buildToolCard(String title, String description, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}