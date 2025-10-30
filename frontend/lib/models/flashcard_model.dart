class Flashcard {
  final String id;
  final String documentId;
  final String frontText;
  final String backText;
  final DateTime createdAt;
  final DateTime? lastReviewed;
  final int reviewCount;
  final double confidenceLevel;

  Flashcard({
    required this.id,
    required this.documentId,
    required this.frontText,
    required this.backText,
    required this.createdAt,
    this.lastReviewed,
    this.reviewCount = 0,
    this.confidenceLevel = 0.5,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? '',
      documentId: map['documentId'] ?? '',
      frontText: map['frontText'] ?? '',
      backText: map['backText'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      lastReviewed: map['lastReviewed'] != null ? DateTime.parse(map['lastReviewed']) : null,
      reviewCount: map['reviewCount'] ?? 0,
      confidenceLevel: map['confidenceLevel']?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'frontText': frontText,
      'backText': backText,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewed': lastReviewed?.toIso8601String(),
      'reviewCount': reviewCount,
      'confidenceLevel': confidenceLevel,
    };
  }
}