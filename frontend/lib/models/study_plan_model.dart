class StudyPlan {
  final String id;
  final String userId;
  final String documentId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<StudySession> sessions;
  final bool isCompleted;

  StudyPlan({
    required this.id,
    required this.userId,
    required this.documentId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.sessions,
    this.isCompleted = false,
  });

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      documentId: map['documentId'] ?? '',
      title: map['title'] ?? 'Study Plan',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      sessions: List<StudySession>.from(
          map['sessions']?.map((x) => StudySession.fromMap(x)) ?? []),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'documentId': documentId,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'sessions': sessions.map((x) => x.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }
}

class StudySession {
  final String id;
  final DateTime date;
  final String topic;
  final String description;
  final Duration duration;
  final bool isCompleted;

  StudySession({
    required this.id,
    required this.date,
    required this.topic,
    required this.description,
    required this.duration,
    this.isCompleted = false,
  });

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      topic: map['topic'] ?? '',
      description: map['description'] ?? '',
      duration: Duration(minutes: map['durationMinutes'] ?? 30),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'topic': topic,
      'description': description,
      'durationMinutes': duration.inMinutes,
      'isCompleted': isCompleted,
    };
  }
}