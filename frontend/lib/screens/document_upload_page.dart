import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:docuverse/services/api_service.dart';
import 'package:docuverse/services/storage_service.dart';
// import 'package:docuverse/services/auth_service.dart';
import 'package:docuverse/widgets/custom_textfield.dart';
import 'package:docuverse/widgets/primary_button.dart';
import 'package:docuverse/utils/validators.dart';

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          if (_titleController.text.isEmpty) {
            _titleController.text = _selectedFile!.name.split('.').first;
          }
        });
      }
    }  catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final storageService = StorageService();
      final file = File(_selectedFile!.path!);

      // Upload to backend
      final document = await ApiService.uploadDocument(
        file,
        _titleController.text.trim(),
      );

      // Save metadata to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await storageService.saveDocumentMetadata(document, user.uid);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: document,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Document Title',
                validator: Validators.validateDocumentTitle,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedFile == null
                            ? 'Tap to select a document'
                            : _selectedFile!.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_selectedFile != null)
                        Text(
                          '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Upload Document',
                onPressed: _uploadFile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}