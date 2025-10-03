// screens/documents.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:docuverse/services/auth_service.dart';
import 'package:docuverse/services/file_storage_service.dart';
import 'package:docuverse/models/folder_model.dart';
import 'package:docuverse/models/file_model.dart';
import 'package:docuverse/constants/app_constants.dart';
import 'package:docuverse/widgets/bottom_navigation.dart';
import 'package:docuverse/widgets/app_logo.dart';
import 'package:docuverse/screens/folder_view.dart';
import 'package:docuverse/utils/file_utils.dart';
import 'package:docuverse/widgets/file_management_dialog.dart';

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
  List<FolderModel> folders = [];
  List<FileModel> uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedFolders = await FileStorageService.getRootFolders();
    final loadedFiles = await FileStorageService.getUnorganizedFiles();
    
    setState(() {
      folders = loadedFolders;
      uploadedFiles = loadedFiles;
    });
  }

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
              onPressed: () async {
                if (folderName.isNotEmpty) {
                  final newFolder = FolderModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: folderName,
                    createdAt: DateTime.now(),
                  );
                  
                  await FileStorageService.addFolder(newFolder);
                  _loadData();
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

  void _openFolder(FolderModel folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderViewScreen(folder: folder),
      ),
    );
  }

  void _deleteFolder(FolderModel folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FileStorageService.deleteFolder(folder.id);
              _loadData();
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

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        List<FileModel> newFiles = [];
        
        for (var file in result.files) {
          final fileModel = FileModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + file.name.hashCode.toString(),
            name: file.name,
            path: file.path ?? '',
            type: file.extension ?? '',
            size: file.size,
            uploadedAt: DateTime.now(),
          );
          newFiles.add(fileModel);
        }
        
        await FileStorageService.addFiles(newFiles);
        _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} file(s) uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick files'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getFileIcon(String fileName) {
    return FileUtils.getFileIcon(fileName);
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

  void _showFileManagement(FileModel file) {
    showDialog(
      context: context,
      builder: (context) => FileManagementDialog(
        file: file,
        onFileUpdated: _loadData,
      ),
    );
  }

  void _renameFolder(FolderModel folder) {
    showDialog(
      context: context,
      builder: (context) {
        String newName = folder.name;
        return AlertDialog(
          title: const Text('Rename Folder'),
          content: TextField(
            controller: TextEditingController(text: folder.name),
            onChanged: (value) => newName = value,
            decoration: const InputDecoration(
              hintText: 'Enter new folder name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty && newName != folder.name) {
                  await FileStorageService.renameFolder(folder.id, newName);
                  _loadData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Folder renamed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
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
                    GestureDetector(
                      onTap: _pickFiles,
                      child: Container(
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
                    ),
                    const SizedBox(height: 16),

                    // Choose Files Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _pickFiles,
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
                    ...folders.map((folder) {
                      return Column(
                        children: [
                          Dismissible(
                            key: Key(folder.id),
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
                              _deleteFolder(folder);
                              return false;
                            },
                            child: _buildFolderItem(
                              folder.name,
                              folder.documentCount,
                              Icons.folder_open,
                              onTap: () => _openFolder(folder),
                              onRename: () => _renameFolder(folder),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                    
                    // Uploaded Files Section
                    if (uploadedFiles.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Uploaded Files',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...uploadedFiles.map((file) => Column(
                        children: [
                          _buildDocumentItem(
                            file.name,
                            file.typeWithDate,
                            _getFileIcon(file.name),
                            file,
                            onManage: () => _showFileManagement(file),
                          ),
                          const SizedBox(height: 8),
                        ],
                      )).toList(),
                    ],
                    
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

  Widget _buildFolderItem(String title, String subtitle, IconData icon, {VoidCallback? onTap, VoidCallback? onRename}) {
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRename != null)
                  GestureDetector(
                    onTap: onRename,
                    child: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.launch, size: 18, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String title, String details, IconData icon, FileModel file, {VoidCallback? onManage}) {
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
              child: Icon(icon, size: 24, color: FileUtils.getFileColor(file.name)),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onManage != null)
                  GestureDetector(
                    onTap: onManage,
                    child: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.star_border, size: 20, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}