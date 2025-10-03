import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/folder_model.dart';
import '../models/file_model.dart';

class FileStorageService {
  static const String _foldersKey = 'user_folders';
  static const String _filesKey = 'user_files';

  // Folder operations
  static Future<List<FolderModel>> getFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final foldersJson = prefs.getString(_foldersKey);
    
    if (foldersJson != null) {
      final List<dynamic> foldersList = json.decode(foldersJson);
      return foldersList.map((folder) => FolderModel.fromJson(folder)).toList();
    }
    
    // Return default folders for first time users
    final defaultFolders = [
      FolderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Research Papers',
        createdAt: DateTime.now(),
      ),
      FolderModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        name: 'Course Materials',
        createdAt: DateTime.now(),
      ),
    ];
    
    await saveFolders(defaultFolders);
    return defaultFolders;
  }

  static Future<void> saveFolders(List<FolderModel> folders) async {
    final prefs = await SharedPreferences.getInstance();
    final foldersJson = json.encode(folders.map((f) => f.toJson()).toList());
    await prefs.setString(_foldersKey, foldersJson);
  }

  static Future<void> addFolder(FolderModel folder) async {
    final folders = await getFolders();
    folders.add(folder);
    await saveFolders(folders);
  }

  static Future<void> deleteFolder(String folderId) async {
    final folders = await getFolders();
    folders.removeWhere((folder) => folder.id == folderId);
    await saveFolders(folders);
    
    // Also remove files in this folder
    final files = await getFiles();
    files.removeWhere((file) => file.folderId == folderId);
    await saveFiles(files);
  }

  // File operations
  static Future<List<FileModel>> getFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = prefs.getString(_filesKey);
    
    if (filesJson != null) {
      final List<dynamic> filesList = json.decode(filesJson);
      return filesList.map((file) => FileModel.fromJson(file)).toList();
    }
    
    return [];
  }

  static Future<void> saveFiles(List<FileModel> files) async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = json.encode(files.map((f) => f.toJson()).toList());
    await prefs.setString(_filesKey, filesJson);
  }

  static Future<void> addFile(FileModel file) async {
    final files = await getFiles();
    files.add(file);
    await saveFiles(files);
  }

  static Future<void> addFiles(List<FileModel> newFiles) async {
    final files = await getFiles();
    files.addAll(newFiles);
    await saveFiles(files);
  }

  static Future<void> deleteFile(String fileId) async {
    final files = await getFiles();
    files.removeWhere((file) => file.id == fileId);
    await saveFiles(files);
  }

  static Future<List<FileModel>> getFilesInFolder(String folderId) async {
    final files = await getFiles();
    return files.where((file) => file.folderId == folderId).toList();
  }

  static Future<List<FileModel>> getUnorganizedFiles() async {
    final files = await getFiles();
    return files.where((file) => file.folderId == null).toList();
  }

  static Future<void> moveFileToFolder(String fileId, String? folderId) async {
    final files = await getFiles();
    final fileIndex = files.indexWhere((file) => file.id == fileId);
    
    if (fileIndex != -1) {
      files[fileIndex] = FileModel(
        id: files[fileIndex].id,
        name: files[fileIndex].name,
        path: files[fileIndex].path,
        type: files[fileIndex].type,
        size: files[fileIndex].size,
        uploadedAt: files[fileIndex].uploadedAt,
        folderId: folderId,
      );
      await saveFiles(files);
    }
  }

  static Future<void> updateFolderFileCount(String folderId) async {
    final folders = await getFolders();
    final files = await getFilesInFolder(folderId);
    
    final folderIndex = folders.indexWhere((folder) => folder.id == folderId);
    if (folderIndex != -1) {
      folders[folderIndex] = folders[folderIndex].copyWith(
        fileIds: files.map((file) => file.id).toList(),
      );
      await saveFolders(folders);
    }
  }

  static Future<void> renameFolder(String folderId, String newName) async {
    final folders = await getFolders();
    final folderIndex = folders.indexWhere((folder) => folder.id == folderId);
    
    if (folderIndex != -1) {
      folders[folderIndex] = folders[folderIndex].copyWith(name: newName);
      await saveFolders(folders);
    }
  }

  static Future<List<FolderModel>> getSubfolders(String parentFolderId) async {
    final folders = await getFolders();
    return folders.where((folder) => folder.parentFolderId == parentFolderId).toList();
  }

  static Future<List<FolderModel>> getRootFolders() async {
    final folders = await getFolders();
    return folders.where((folder) => folder.parentFolderId == null).toList();
  }
}