class Document {
  final String id;
  final String title;
  final String type;
  final String uploadDate;
  final String? thumbnailUrl;
  final int? pageCount;
  final String? fileUrl;

  Document({
    required this.id,
    required this.title,
    required this.type,
    required this.uploadDate,
    this.thumbnailUrl,
    this.pageCount,
    this.fileUrl,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled Document',
      type: map['type'] ?? 'PDF',
      uploadDate: map['uploadDate'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      pageCount: map['pageCount'],
      fileUrl: map['fileUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'uploadDate': uploadDate,
      'thumbnailUrl': thumbnailUrl,
      'pageCount': pageCount,
      'fileUrl': fileUrl,
    };
  }
}