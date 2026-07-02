class EventNote {
  final String   noteId;
  final String   eventId;
  final String   content;
  final DateTime timestamp;

  EventNote({
    required this.noteId,
    required this.eventId,
    required this.content,
    required this.timestamp,
  });

  factory EventNote.fromMap(String id, Map<String, dynamic> map) {
    return EventNote(
      noteId:    id,
      eventId:   map['eventId']   ?? '',
      content:   map['content']   ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId':   eventId,
      'content':   content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  EventNote copyWith({String? content}) {
    return EventNote(
      noteId:    noteId,
      eventId:   eventId,
      content:   content ?? this.content,
      timestamp: timestamp,
    );
  }
}