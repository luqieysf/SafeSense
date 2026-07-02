import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';

class ChildRoutineScreen extends StatefulWidget {
  const ChildRoutineScreen({super.key});

  @override
  State<ChildRoutineScreen> createState() => _ChildRoutineScreenState();
}

class _ChildRoutineScreenState extends State<ChildRoutineScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  Future<void> _loadTasks() async {
    final child = Provider.of<ChildProvider>(context, listen: false);
    final tasks = Provider.of<TaskProvider>(context, listen: false);
    if (child.childProfile == null) return;
    await tasks.loadTasks(child.childProfile!.childId);
  }

  Future<void> _toggleTask(String taskId, bool current, int tokens) async {
    final taskProv  = Provider.of<TaskProvider>(context, listen: false);
    final childProv = Provider.of<ChildProvider>(context, listen: false);
    final child     = childProv.childProfile;
    if (child == null) return;

    await taskProv.toggleComplete(taskId, !current);

    // award tokens when completing, deduct when unchecking
    final delta       = !current ? tokens : -tokens;
    final newBalance  = (child.tokenBalance + delta).clamp(0, 99999);
    await childProv.updateTokenBalance(child.childId, newBalance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // header
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
                  const Text("Today's Tasks",
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                ],
              ),
            ),

            // task list
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (_, taskProv, __) {
                  if (taskProv.isLoading) {
                    return const Center(child: CircularProgressIndicator(
                        color: AppColors.sageGreen));
                  }
                  if (taskProv.tasks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt,
                                color: AppColors.dustyGray, size: 60),
                            SizedBox(height: 16),
                            Text(
                              'No tasks yet.\n'
                                  'Your teacher or caregiver\n'
                                  'will add tasks for you!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, color: AppColors.darkGray),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:       taskProv.tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder:     (_, i) {
                      final task        = taskProv.tasks[i];
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
                            // icon
                            Text(task.icon.isEmpty ? '📌' : task.icon,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            // name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text('+${task.tokensEarned} token${task.tokensEarned == 1 ? '' : 's'}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.darkGray,
                                          )),
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
                            // checkbox
                            GestureDetector(
                              onTap: () => _toggleTask(
                                  task.taskId, isCompleted,
                                  task.tokensEarned),
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.sageGreen
                                      : AppColors.pastelTeal,
                                  shape: BoxShape.circle,
                                ),
                                child: isCompleted
                                    ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // token summary
            Consumer2<TaskProvider, ChildProvider>(
              builder: (_, taskProv, childProv, __) {
                final completed = taskProv.tasks
                    .where((t) => t.isCompleted).length;
                final balance   = childProv.tokenBalance;
                return Container(
                  width:   double.infinity,
                  margin:  const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        AppColors.warmBeige,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$completed / ${taskProv.tasks.length} tasks completed today',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w600,
                          color:      AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Total tokens: $balance',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.darkGray)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}