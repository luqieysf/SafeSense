class ClassGroup {
  final String       classId;
  final String       className;
  final String       teacherId;
  final List<String> studentIds;

  ClassGroup({
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.studentIds,
  });

  factory ClassGroup.fromMap(String id, Map<String, dynamic> map) {
    return ClassGroup(
      classId:    id,
      className:  map['className']  ?? '',
      teacherId:  map['teacherId']  ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'className':  className,
    'teacherId':  teacherId,
    'studentIds': studentIds,
  };

  ClassGroup copyWith({String? className, List<String>? studentIds}) =>
      ClassGroup(
        classId:    classId,
        className:  className   ?? this.className,
        teacherId:  teacherId,
        studentIds: studentIds  ?? this.studentIds,
      );
}