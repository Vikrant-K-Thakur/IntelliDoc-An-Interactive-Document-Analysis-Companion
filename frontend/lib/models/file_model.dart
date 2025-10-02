class FileModel {
  final String id;
  final String name;
  final String path;
  final String type;
  final int size;
  final DateTime uploadedAt;
  final String? folderId;

  FileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.uploadedAt,
    this.folderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'uploadedAt': uploadedAt.toIso8601String(),
      'folderId': folderId,
    };
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      type: json['type'],
      size: json['size'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      folderId: json['folderId'],
    );
  }

  String get extension => name.split('.').last.toUpperCase();
  
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get typeWithDate => '$extension • ${uploadedAt.toString().split(' ')[0]}';
}