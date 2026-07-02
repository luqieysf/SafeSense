class OverstimulationEvent {
  final String   eventId;
  final String   childId;
  final String   eventType;    // child-initiated / manual
  final DateTime dateTime;
  final String   notes;
  final bool     audioStopped; // did child press stop?

  OverstimulationEvent({
    required this.eventId,
    required this.childId,
    required this.eventType,
    required this.dateTime,
    required this.notes,
    required this.audioStopped,
  });

  factory OverstimulationEvent.fromMap(String id, Map<String, dynamic> map) {
    return OverstimulationEvent(
      eventId:      id,
      childId:      map['childId']      ?? '',
      eventType:    map['eventType']    ?? 'child-initiated',
      dateTime:     DateTime.parse(map['dateTime']),
      notes:        map['notes']        ?? '',
      audioStopped: map['audioStopped'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId':      childId,
      'eventType':    eventType,
      'dateTime':     dateTime.toIso8601String(),
      'notes':        notes,
      'audioStopped': audioStopped,
    };
  }

  OverstimulationEvent copyWith({
    String?   eventType,
    DateTime? dateTime,
    String?   notes,
    bool?     audioStopped,
  }) {
    return OverstimulationEvent(
      eventId:      eventId,
      childId:      childId,
      eventType:    eventType    ?? this.eventType,
      dateTime:     dateTime     ?? this.dateTime,
      notes:        notes        ?? this.notes,
      audioStopped: audioStopped ?? this.audioStopped,
    );
  }
}