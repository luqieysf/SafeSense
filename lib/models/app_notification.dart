class AppNotification {
  final String   notificationId;
  final String   userId;
  final String   childId;
  final String   childName;
  final String   eventId;
  final String   message;
  final DateTime timestamp;
  final bool     isRead;

  AppNotification({
    required this.notificationId,
    required this.userId,
    required this.childId,
    required this.childName,
    required this.eventId,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      notificationId: id,
      userId:         map['userId']    ?? '',
      childId:        map['childId']   ?? '',
      childName:      map['childName'] ?? '',
      eventId:        map['eventId']   ?? '',
      message:        map['message']   ?? '',
      timestamp:      DateTime.parse(map['timestamp']),
      isRead:         map['isRead']    ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':    userId,
    'childId':   childId,
    'childName': childName,
    'eventId':   eventId,
    'message':   message,
    'timestamp': timestamp.toIso8601String(),
    'isRead':    isRead,
  };
}