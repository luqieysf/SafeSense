import 'package:flutter/material.dart';
import '../../models/child_profile.dart';
import '../../models/routine_task.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class CaregiverChildTasksScreen extends StatefulWidget {
  const CaregiverChildTasksScreen({super.key});

  @override
  State<CaregiverChildTasksScreen> createState() =>
      _CaregiverChildTasksScreenState();
}

class _CaregiverChildTasksScreenState
    extends State<CaregiverChildTasksScreen> {
  final _db = FirestoreService();
  ChildProfile? _child;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _child ??= ModalRoute.of(context)!.settings.arguments as ChildProfile?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.darkGray, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${_child?.name ?? ''} — Tasks",
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dustyGray.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('View Only',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.dustyGray)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _child == null
                  ? const Center(child: Text('Child not found.'))
                  : StreamBuilder<List<RoutineTask>>(
                stream: _db.streamTasks(_child!.childId),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        color: AppColors.sageGreen));
                  }
                  final tasks = snap.data ?? [];
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt,
                                color: AppColors.dustyGray, size: 60),
                            SizedBox(height: 16),
                            Text('No routine tasks assigned yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.darkGray)),
                          ],
                        ),
                      ),
                    );
                  }

                  final completed = tasks.where((t) => t.isCompleted).length;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warmBeige,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$completed / ${tasks.length} tasks completed',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final task        = tasks[i];
                            final isCompleted = task.isCompleted;
                            final bgColor     = i.isEven
                                ? AppColors.softBlue
                                : AppColors.sageGreen;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? bgColor.withOpacity(0.4)
                                    : bgColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Text(task.icon.isEmpty ? '📌' : task.icon,
                                      style: const TextStyle(fontSize: 28)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.taskName,
                                          style: TextStyle(
                                            fontSize:   16,
                                            fontWeight: FontWeight.w600,
                                            color:      AppColors.darkGray,
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '+${task.tokensEarned} token${task.tokensEarned == 1 ? '' : 's'}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.darkGray,
                                              ),
                                            ),
                                            if (task.isRecurring) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.repeat,
                                                  size: 12,
                                                  color: AppColors.darkGray),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isCompleted
                                        ? Colors.white
                                        : AppColors.darkGray,
                                    size: 22,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
