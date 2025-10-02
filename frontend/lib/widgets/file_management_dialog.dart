import 'package:flutter/material.dart';
import '../models/folder_model.dart';
import '../models/file_model.dart';
import '../services/file_storage_service.dart';

class FileManagementDialog extends StatefulWidget {
  final FileModel file;
  final VoidCallback onFileUpdated;

  const FileManagementDialog({
    super.key,
    required this.file,
    required this.onFileUpdated,
  });

  @override
  State<FileManagementDialog> createState() => _FileManagementDialogState();
}

class _FileManagementDialogState extends State<FileManagementDialog> {
  List<FolderModel> folders = [];
  String? selectedFolderId;

  @override
  void initState() {
    super.initState();
    selectedFolderId = widget.file.folderId;
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final loadedFolders = await FileStorageService.getFolders();
    setState(() {
      folders = loadedFolders;
    });
  }

  Future<void> _moveFile() async {
    await FileStorageService.moveFileToFolder(widget.file.id, selectedFolderId);
    
    // Update folder file counts
    if (widget.file.folderId != null) {
      await FileStorageService.updateFolderFileCount(widget.file.folderId!);
    }
    if (selectedFolderId != null) {
      await FileStorageService.updateFolderFileCount(selectedFolderId!);
    }
    
    widget.onFileUpdated();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File moved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteFile() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${widget.file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FileStorageService.deleteFile(widget.file.id);
              
              // Update folder file count if file was in a folder
              if (widget.file.folderId != null) {
                await FileStorageService.updateFolderFileCount(widget.file.folderId!);
              }
              
              widget.onFileUpdated();
              Navigator.pop(context); // Close delete dialog
              Navigator.pop(context); // Close management dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File deleted successfully'),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage "${widget.file.name}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move to folder:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedFolderId,
                hint: const Text('Select folder'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No folder (Root)'),
                  ),
                  ...folders.map((folder) => DropdownMenuItem<String?>(
                    value: folder.id,
                    child: Text(folder.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedFolderId = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'File Details:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Size: ${widget.file.formattedSize}'),
          Text('Type: ${widget.file.extension}'),
          Text('Uploaded: ${widget.file.uploadedAt.toString().split(' ')[0]}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleteFile,
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: selectedFolderId != widget.file.folderId ? _moveFile : null,
          child: const Text('Move'),
        ),
      ],
    );
  }
}