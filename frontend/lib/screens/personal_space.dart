// screens/personal_space.dart
import 'package:flutter/material.dart';
import 'package:docuverse/services/auth_service.dart';
import 'package:docuverse/constants/app_constants.dart';
import 'package:docuverse/widgets/bottom_navigation.dart';

class PersonalSpaceScreen extends StatefulWidget {
  const PersonalSpaceScreen({super.key});

  @override
  State<PersonalSpaceScreen> createState() => _PersonalSpaceScreenState();
}

class _PersonalSpaceScreenState extends State<PersonalSpaceScreen> {
  int _currentIndex = 3;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Space'),
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
            const Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 25, color: Colors.white),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olivia Rhye',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'olivia.rhye@example.com',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildListItem('Settings', 'Manage profile, preferences & more'),
            const SizedBox(height: 12),
            _buildListItem('Collaboration & Sharing', 'View and manage shared documents'),
            const SizedBox(height: 12),
            _buildListItem('Logout', 'Sign out of your account'),
            const SizedBox(height: 30),
            const Text(
              'My Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildListItem('Starred Files', 'Your favorite documents'),
            const SizedBox(height: 12),
            _buildListItem('My Flashcards', 'Review and organize your flashcards'),
            const SizedBox(height: 12),
            _buildListItem('Download Center', 'Summaries, translations & quizzes'),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Made with',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
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

  Widget _buildListItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }
}