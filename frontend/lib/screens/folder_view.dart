// screens/folder_view.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/folder_model.dart';
import '../models/file_model.dart';
import '../services/file_storage_service.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../utils/file_utils.dart';
import '../widgets/file_management_dialog.dart';

class FolderViewScreen extends StatefulWidget {
  final FolderModel folder;
  
  const FolderViewScreen({super.key, required this.folder});

  @override
  State<FolderViewScreen> createState() => _FolderViewScreenState();
}

class _FolderViewScreenState extends State<FolderViewScreen> {
  List<FileModel> folderFiles = [];

  @override
  void initState() {
    super.initState();
    _loadFolderFiles();
  }

  Future<void> _loadFolderFiles() async {
    final files = await FileStorageService.getFilesInFolder(widget.folder.id);
    setState(() {
      folderFiles = files;
    });
  }

  Future<void> _addFilesToFolder() async {
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
            folderId: widget.folder.id,
          );
          newFiles.add(fileModel);
        }
        
        await FileStorageService.addFiles(newFiles);
        await FileStorageService.updateFolderFileCount(widget.folder.id);
        _loadFolderFiles();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} file(s) added to folder'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add files'),
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
        onFileUpdated: _loadFolderFiles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.folder.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFilesToFolder,
          ),
        ],
      ),
      body: folderFiles.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Folder is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add documents',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: folderFiles.length,
              itemBuilder: (context, index) {
                final file = folderFiles[index];
                return Column(
                  children: [
                    _buildFileItem(file, onManage: () => _showFileManagement(file)),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildFileItem(FileModel file, {VoidCallback? onManage}) {
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
              child: Icon(_getFileIcon(file.name), size: 24, color: FileUtils.getFileColor(file.name)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    file.typeWithDate,
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