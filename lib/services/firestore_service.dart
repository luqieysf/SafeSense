import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_profile.dart';
import '../models/overstimulation_event.dart';
import '../models/routine_task.dart';
import '../models/event_note.dart';
import '../models/pdf_report.dart';
import '../models/audio_file.dart';
import '../models/class_group.dart';
import '../models/app_notification.dart';
import '../models/user_account.dart';
import '../models/handover_note.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════
  // CHILD PROFILE
  // ═══════════════════════════════════════════════════

  Future<ChildProfile?> getChildProfile(String childId) async {
    final doc = await _db.collection('children').doc(childId).get();
    if (!doc.exists) return null;
    return ChildProfile.fromMap(doc.id, doc.data()!);
  }

  Future<ChildProfile?> findChildByPin(String pin) async {
    final snap = await _db
        .collection('children')
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ChildProfile.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Future<void> saveChildProfile(ChildProfile profile) async {
    await _db.collection('children').doc(profile.childId).set(profile.toMap());
  }

  Future<String> createChildProfile(ChildProfile profile) async {
    final doc = await _db.collection('children').add(profile.toMap());
    return doc.id;
  }

  Future<void> linkUserToChild(String childId, String userId) async {
    await _db.collection('children').doc(childId).update({
      'linkedUserIds': FieldValue.arrayUnion([userId]),
    });
    await _db.collection('users').doc(userId).update({
      'linkedChildIds': FieldValue.arrayUnion([childId]),
    });
  }

  Future<List<ChildProfile>> getChildrenForUser(List<String> childIds) async {
    if (childIds.isEmpty) return [];
    final List<ChildProfile> result = [];
    for (final id in childIds) {
      final p = await getChildProfile(id);
      if (p != null) result.add(p);
    }
    return result;
  }

  Future<void> updateTokenBalance(String childId, int newBalance) async {
    await _db.collection('children').doc(childId)
        .update({'tokenBalance': newBalance});
  }

  Future<void> updateChildImageUrl(String childId, String url) async {
    await _db.collection('children').doc(childId)
        .update({'profileImageUrl': url});
  }

  // ═══════════════════════════════════════════════════
  // MONTHLY EVENT COUNT
  // ═══════════════════════════════════════════════════

  Future<void> incrementMonthlyEventCount(String childId) async {
    final now   = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final doc   = await _db.collection('children').doc(childId).get();
    if (!doc.exists) return;

    final lastMonth = doc.data()?['lastEventMonth'] ?? '';
    if (lastMonth == month) {
      await _db.collection('children').doc(childId).update({
        'monthlyEventCount': FieldValue.increment(1),
      });
    } else {
      await _db.collection('children').doc(childId).update({
        'monthlyEventCount': 1,
        'lastEventMonth':    month,
      });
    }
  }

  // ═══════════════════════════════════════════════════
  // EVENTS
  // ═══════════════════════════════════════════════════

  Future<List<OverstimulationEvent>> getEvents(String childId) async {
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('childId', isEqualTo: childId)
        .get();
    final list = snap.docs
        .map((d) => OverstimulationEvent.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  // filter by month
  Future<List<OverstimulationEvent>> getEventsByMonth(
      String childId, String month) async {
    final parts = month.split('-');
    final start = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
    final end   = DateTime(start.year, start.month + 1, 1);
    final all   = await getEvents(childId);
    return all.where((e) =>
    e.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
        e.dateTime.isBefore(end)).toList();
  }

  Future<String> addEvent(OverstimulationEvent event) async {
    final doc = await _db.collection('events').add(event.toMap());
    await incrementMonthlyEventCount(event.childId);
    return doc.id;
  }

  Future<void> updateEvent(OverstimulationEvent event) async {
    await _db.collection('events').doc(event.eventId).update(event.toMap());
  }

  // ═══════════════════════════════════════════════════
  // TASKS
  // ═══════════════════════════════════════════════════

  Future<List<RoutineTask>> getTasks(String childId) async {
    final snap = await _db
        .collection('tasks')
        .where('childId', isEqualTo: childId)
        .get();
    final tasks = snap.docs
        .map((d) => RoutineTask.fromMap(d.id, d.data()))
        .toList();
    return Future.wait(tasks.map(_resetIfStale));
  }

  Future<String> addTask(RoutineTask task) async {
    final doc = await _db.collection('tasks').add(task.toMap());
    return doc.id;
  }

  Future<void> updateTask(RoutineTask task) async {
    await _db.collection('tasks').doc(task.taskId).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> markTaskComplete(String taskId, bool isCompleted,
      {bool isRecurring = false}) async {
    final updates = <String, dynamic>{'isCompleted': isCompleted};
    if (isRecurring && isCompleted) {
      updates['lastCompletedDate'] = RoutineTask.todayKey();
    }
    await _db.collection('tasks').doc(taskId)
        .update(updates);
  }

  // A recurring ("Everyday") task's `isCompleted` flag only reflects
  // whether it was completed on `lastCompletedDate`. Once that date isn't
  // today anymore, lazily flip it back to incomplete so the child sees a
  // fresh checklist each day without any cron job / scheduled reset.
  Future<RoutineTask> _resetIfStale(RoutineTask task) async {
    final isStale = task.isRecurring &&
        task.isCompleted &&
        task.lastCompletedDate != RoutineTask.todayKey();
    if (!isStale) return task;
    await _db.collection('tasks').doc(task.taskId)
        .update({'isCompleted': false});
    return task.copyWith(isCompleted: false);
  }

  // ═══════════════════════════════════════════════════
  // NOTES
  // ═══════════════════════════════════════════════════

  Future<List<EventNote>> getNotes(String eventId) async {
    final snap = await _db
        .collection('notes')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp')
        .get();
    return snap.docs.map((d) => EventNote.fromMap(d.id, d.data())).toList();
  }

  Future<void> addNote(EventNote note) async {
    await _db.collection('notes').add(note.toMap());
  }

  // ═══════════════════════════════════════════════════
  // HANDOVER NOTES (caregiver → parent daily notes)
  // ═══════════════════════════════════════════════════

  Stream<List<HandoverNote>> streamHandoverNotes(String childId) {
    return _db
        .collection('handoverNotes')
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => HandoverNote.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> addHandoverNote(HandoverNote note) async {
    await _db.collection('handoverNotes').add(note.toMap());
  }

  // ═══════════════════════════════════════════════════
  // CLASS GROUPS
  // ═══════════════════════════════════════════════════

  Future<List<ClassGroup>> getClasses(String teacherId) async {
    final snap = await _db
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    return snap.docs
        .map((d) => ClassGroup.fromMap(d.id, d.data()))
        .toList();
  }

  Future<String> createClass(ClassGroup group) async {
    final doc = await _db.collection('classes').add(group.toMap());
    return doc.id;
  }

  Future<void> renameClass(String classId, String newName) async {
    await _db.collection('classes').doc(classId)
        .update({'className': newName});
  }

  Future<void> deleteClass(String classId) async {
    await _db.collection('classes').doc(classId).delete();
  }

  Future<void> addStudentToClass(String classId, String studentId) async {
    // remove from previous class first
    final oldClasses = await _db
        .collection('classes')
        .where('studentIds', arrayContains: studentId)
        .get();
    for (final doc in oldClasses.docs) {
      await doc.reference.update({
        'studentIds': FieldValue.arrayRemove([studentId]),
      });
    }
    // add to new class
    await _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayUnion([studentId]),
    });
    // update classId on child
    await _db.collection('children').doc(studentId)
        .update({'classId': classId});
  }

  Future<void> removeStudentFromClass(
      String classId, String studentId) async {
    await _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayRemove([studentId]),
    });
    await _db.collection('children').doc(studentId)
        .update({'classId': ''});
  }

  // ═══════════════════════════════════════════════════
  // USER PROFILE
  // ═══════════════════════════════════════════════════

  Future<UserAccount?> getUserAccount(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserAccount.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateUserProfile(String userId, {
    String? name, String? profileImageUrl,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name             != null) updates['name']            = name;
    if (profileImageUrl  != null) updates['profileImageUrl'] = profileImageUrl;
    if (updates.isEmpty) return;
    await _db.collection('users').doc(userId).update(updates);
  }

  // ═══════════════════════════════════════════════════
  // AUDIO + REPORTS
  // ═══════════════════════════════════════════════════

  Future<AudioFile?> getAudioFile(String childId) async {
    final snap = await _db
        .collection('audioFiles')
        .where('childId', isEqualTo: childId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return AudioFile.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Future<void> saveAudioFile(AudioFile audio) async {
    await _db.collection('audioFiles').add(audio.toMap());
  }

  Future<List<PdfReport>> getReports(String childId) async {
    final snap = await _db
        .collection('reports')
        .where('childId', isEqualTo: childId)
        .orderBy('month', descending: true)
        .get();
    return snap.docs.map((d) => PdfReport.fromMap(d.id, d.data())).toList();
  }

  Future<void> saveReport(PdfReport report) async {
    await _db.collection('reports').add(report.toMap());
  }

  // ═══════════════════════════════════════════════════
  // REAL-TIME STREAMS
  // ═══════════════════════════════════════════════════

  Stream<List<OverstimulationEvent>> streamEvents(String childId) {
    return FirebaseFirestore.instance
        .collection('events')
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => OverstimulationEvent.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    });
  }

  Stream<ChildProfile?> streamChildProfile(String childId) {
    return FirebaseFirestore.instance
        .collection('children')
        .doc(childId)
        .snapshots()
        .map((doc) => doc.exists
        ? ChildProfile.fromMap(doc.id, doc.data()!)
        : null);
  }

  Stream<List<RoutineTask>> streamTasks(String childId) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('childId', isEqualTo: childId)
        .snapshots()
        .asyncMap((snap) async {
      final tasks = snap.docs
          .map((d) => RoutineTask.fromMap(d.id, d.data()))
          .toList();
      return Future.wait(tasks.map(_resetIfStale));
    });
  }

  // ═══════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════

  Future<void> notifyLinkedUsers({
    required ChildProfile child,
    required String       eventId,
    required DateTime     dateTime,
  }) async {
    if (child.linkedUserIds.isEmpty) return;
    final batch = _db.batch();
    for (final uid in child.linkedUserIds) {
      final ref = _db.collection('notifications').doc();
      batch.set(ref, {
        'userId':    uid,
        'childId':   child.childId,
        'childName': child.name,
        'eventId':   eventId,
        'message':   '${child.name} pressed the overwhelmed button',
        'timestamp': dateTime.toIso8601String(),
        'isRead':    false,
      });
    }
    await batch.commit();
  }

  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => AppNotification.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Stream<int> streamUnreadCount(String userId) {
    return streamNotifications(userId)
        .map((list) => list.where((n) => !n.isRead).length);
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<OverstimulationEvent?> getEventById(String eventId) async {
    final doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return null;
    return OverstimulationEvent.fromMap(doc.id, doc.data()!);
  }

}

