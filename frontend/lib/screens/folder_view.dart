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
  List<FolderModel> subfolders = [];

  @override
  void initState() {
    super.initState();
    _loadFolderContent();
  }

  Future<void> _loadFolderContent() async {
    final files = await FileStorageService.getFilesInFolder(widget.folder.id);
    final folders = await FileStorageService.getSubfolders(widget.folder.id);
    setState(() {
      folderFiles = files;
      subfolders = folders;
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
        _loadFolderContent();
        
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
        onFileUpdated: _loadFolderContent,
      ),
    );
  }

  void _createSubfolder() {
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
                    parentFolderId: widget.folder.id,
                  );
                  
                  await FileStorageService.addFolder(newFolder);
                  _loadFolderContent();
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_files') {
                _addFilesToFolder();
              } else if (value == 'new_folder') {
                _createSubfolder();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_files',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Add Files'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_folder',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder),
                    SizedBox(width: 8),
                    Text('New Folder'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: (folderFiles.isEmpty && subfolders.isEmpty)
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
                      'Use menu to add files or folders',
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
              itemCount: subfolders.length + folderFiles.length,
              itemBuilder: (context, index) {
                if (index < subfolders.length) {
                  final folder = subfolders[index];
                  return Column(
                    children: [
                      _buildSubfolderItem(folder),
                      const SizedBox(height: 12),
                    ],
                  );
                } else {
                  final file = folderFiles[index - subfolders.length];
                  return Column(
                    children: [
                      _buildFileItem(file, onManage: () => _showFileManagement(file)),
                      const SizedBox(height: 12),
                    ],
                  );
                }
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

  Widget _buildSubfolderItem(FolderModel folder) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderViewScreen(folder: folder),
          ),
        );
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
            Icon(Icons.folder, size: 28, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    folder.documentCount,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}