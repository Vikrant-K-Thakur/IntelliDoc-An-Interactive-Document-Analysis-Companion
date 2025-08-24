import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:docuverse/models/document_model.dart';
import 'package:docuverse/services/auth_service.dart';
import 'package:docuverse/services/storage_service.dart';
import 'package:docuverse/widgets/doc_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StorageService _storageService;
  late final AuthService _authService;
  List<Document> _documents = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _storageService = StorageService();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _userId = user.uid;
    });

    try {
      final documents = await _storageService.getUserDocuments(user.uid);
      if (mounted) {
        setState(() => _documents = documents);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load documents: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    if (_userId == null) return;

    try {
      await _storageService.deleteDocument(_userId!, documentId);
      if (mounted) {
        setState(() {
          _documents.removeWhere((doc) => doc.id == documentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete document: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      await _authService.setLoggedIn(false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/upload');
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.folder_open,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No documents yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap the + button to upload your first document',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDocuments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final document = _documents[index];
                      return DocTile(
                        document: document,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/result',
                            arguments: document,
                          );
                        },
                        onDelete: () => _deleteDocument(document.id),
                      );
                    },
                  ),
                ),
    );
  }
}