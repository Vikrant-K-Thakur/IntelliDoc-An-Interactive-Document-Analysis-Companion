// screens/documents.dart
import 'package:flutter/material.dart';
import 'package:docuverse/services/auth_service.dart';
import 'package:docuverse/constants/app_constants.dart';
import 'package:docuverse/widgets/bottom_navigation.dart';
import 'package:docuverse/widgets/app_logo.dart';
import 'package:docuverse/screens/folder_view.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const DocumentsScreenContent(),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        context: context,
      ),
    );
  }
}

class DocumentsScreenContent extends StatefulWidget {
  const DocumentsScreenContent({super.key});

  @override
  State<DocumentsScreenContent> createState() => _DocumentsScreenContentState();
}

class _DocumentsScreenContentState extends State<DocumentsScreenContent> {
  List<Map<String, String>> folders = [
    {'name': 'Research Papers', 'count': '12 Documents'},
    {'name': 'Course Materials', 'count': '8 Documents'},
  ];

  void _createNewFolder() {
    showDialog(
      context: context,
      builder: (context) {
        String folderName = '';
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            onChanged: (value) => folderName = value,
            decoration: const InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (folderName.isNotEmpty) {
                  setState(() {
                    folders.add({
                      'name': folderName,
                      'count': '0 Documents',
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _openFolder(String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderViewScreen(folderName: folderName),
      ),
    );
  }

  void _deleteFolder(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folders[index]['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                folders.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Folder deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(
                        size: 32,
                        showText: false,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search documents...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upload Section
                    const Text(
                      'Upload Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag & drop files or click to upload PDF, Word, PPT, Scanned Images.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // Upload Area
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[200]!, width: 2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[50],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.upload_file, size: 48, color: Colors.blue[400]),
                          const SizedBox(height: 12),
                          const Text(
                            'Drag & Drop Your Files Here',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Max file size: 25MB',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Choose Files Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_drive_file, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Choose Files',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Your Documents
                    const Text(
                      'Your Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sort, Filter and New Folder buttons
                    Row(
                      children: [
                        _buildFilterButton('Sort By', Icons.sort),
                        const SizedBox(width: 10),
                        _buildFilterButton('Filter', Icons.filter_list),
                        const SizedBox(width: 10),
                        _buildFilterButton('New Folder', Icons.create_new_folder, onTap: _createNewFolder),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Document Folders
                    ...folders.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> folder = entry.value;
                      return Column(
                        children: [
                          Dismissible(
                            key: Key(folder['name']!),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              _deleteFolder(index);
                              return false;
                            },
                            child: _buildFolderItem(
                              folder['name']!,
                              folder['count']!,
                              Icons.folder_open,
                              onTap: () => _openFolder(folder['name']!),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.launch, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String title, String details, IconData icon) {
    return GestureDetector(
      onTap: () {
        _checkAuthAndNavigate(AppConstants.aiDocumentRoute);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.star_border, size: 20, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}