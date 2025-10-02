class FolderModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> fileIds;

  FolderModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.fileIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'fileIds': fileIds,
    };
  }

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      fileIds: List<String>.from(json['fileIds'] ?? []),
    );
  }

  String get documentCount => '${fileIds.length} Documents';

  FolderModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? fileIds,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      fileIds: fileIds ?? this.fileIds,
    );
  }
}