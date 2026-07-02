class RoutineTask {
  final String    taskId;
  final String    childId;
  final String    taskName;
  final String    icon;
  final DateTime? scheduledTime; // optional
  final bool      reminder;
  final bool      isCompleted;
  final int       tokensEarned;
  final bool      isRecurring;       // true = "Everyday Task"
  final String    lastCompletedDate; // yyyy-MM-dd, only used when isRecurring

  RoutineTask({
    required this.taskId,
    required this.childId,
    required this.taskName,
    required this.icon,
    this.scheduledTime,
    required this.reminder,
    required this.isCompleted,
    required this.tokensEarned,
    this.isRecurring = false,
    this.lastCompletedDate = '',
  });

  factory RoutineTask.fromMap(String id, Map<String, dynamic> map) {
    return RoutineTask(
      taskId:            id,
      childId:           map['childId']           ?? '',
      taskName:          map['taskName']          ?? '',
      icon:              map['icon']              ?? '',
      scheduledTime:     map['scheduledTime'] != null
          ? DateTime.parse(map['scheduledTime'])
          : null,
      reminder:          map['reminder']          ?? false,
      isCompleted:       map['isCompleted']       ?? false,
      tokensEarned:      map['tokensEarned']      ?? 1,
      isRecurring:       map['isRecurring']       ?? false,
      lastCompletedDate: map['lastCompletedDate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId':           childId,
      'taskName':          taskName,
      'icon':              icon,
      'scheduledTime':     scheduledTime?.toIso8601String(),
      'reminder':          reminder,
      'isCompleted':       isCompleted,
      'tokensEarned':      tokensEarned,
      'isRecurring':       isRecurring,
      'lastCompletedDate': lastCompletedDate,
    };
  }

  RoutineTask copyWith({
    String?    taskName,
    String?    icon,
    DateTime?  scheduledTime,
    bool?      reminder,
    bool?      isCompleted,
    int?       tokensEarned,
    bool?      isRecurring,
    String?    lastCompletedDate,
  }) {
    return RoutineTask(
      taskId:            taskId,
      childId:           childId,
      taskName:          taskName          ?? this.taskName,
      icon:              icon              ?? this.icon,
      scheduledTime:     scheduledTime     ?? this.scheduledTime,
      reminder:          reminder          ?? this.reminder,
      isCompleted:       isCompleted       ?? this.isCompleted,
      tokensEarned:      tokensEarned      ?? this.tokensEarned,
      isRecurring:       isRecurring       ?? this.isRecurring,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  // yyyy-MM-dd key used to track which day a recurring task was last
  // completed on, so completion can lazily reset when a new day starts.
  static String todayKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
