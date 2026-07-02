class HandoverNote {
  final String   noteId;
  final String   childId;
  final String   authorId;
  final String   authorName;
  final String   content;
  final DateTime timestamp;

  HandoverNote({
    required this.noteId,
    required this.childId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });

  factory HandoverNote.fromMap(String id, Map<String, dynamic> map) {
    return HandoverNote(
      noteId:     id,
      childId:    map['childId']    ?? '',
      authorId:   map['authorId']   ?? '',
      authorName: map['authorName'] ?? '',
      content:    map['content']    ?? '',
      timestamp:  map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId':    childId,
      'authorId':   authorId,
      'authorName': authorName,
      'content':    content,
      'timestamp':  timestamp.toIso8601String(),
    };
  }
}
