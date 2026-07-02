import 'package:flutter/material.dart';
import '../models/routine_task.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  List<RoutineTask> _tasks       = [];
  bool              _isLoading   = false;
  String?           _errorMessage;

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<RoutineTask> get tasks         => _tasks;
  bool              get isLoading     => _isLoading;
  String?           get errorMessage  => _errorMessage;
  int               get completedCount =>
      _tasks.where((t) => t.isCompleted).length;

  // ─── Load tasks for a child ────────────────────────────────────────────────
  Future<void> loadTasks(String childId) async {
    _setLoading(true);
    try {
      _tasks = await _db.getTasks(childId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // ─── Add task ──────────────────────────────────────────────────────────────
  Future<void> addTask(RoutineTask task) async {
    try {
      final newId = await _db.addTask(task);
      // add to local list with real Firestore id
      _tasks.add(RoutineTask(
        taskId:            newId,
        childId:           task.childId,
        taskName:          task.taskName,
        icon:              task.icon,
        scheduledTime:     task.scheduledTime,
        reminder:          task.reminder,
        isCompleted:       task.isCompleted,
        tokensEarned:      task.tokensEarned,
        isRecurring:       task.isRecurring,
        lastCompletedDate: task.lastCompletedDate,
      ));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ─── Mark task complete / incomplete ───────────────────────────────────────
  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    try {
      final index = _tasks.indexWhere((t) => t.taskId == taskId);
      final isRecurring = index != -1 ? _tasks[index].isRecurring : false;
      await _db.markTaskComplete(taskId, isCompleted, isRecurring: isRecurring);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: isCompleted,
          lastCompletedDate: (isRecurring && isCompleted)
              ? RoutineTask.todayKey()
              : _tasks[index].lastCompletedDate,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ─── Delete task ───────────────────────────────────────────────────────────
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.deleteTask(taskId);
      _tasks.removeWhere((t) => t.taskId == taskId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}