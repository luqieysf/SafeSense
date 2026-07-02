import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';

class ChildTokenScreen extends StatelessWidget {
  const ChildTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
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
                        color:        AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.darkGray, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('My Tokens',
                      style: TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.bold,
                        color:      AppColors.darkGray,
                      )),
                ],
              ),
            ),

            const Spacer(),

            // token circle — uses real balance from provider
            Consumer<ChildProvider>(
              builder: (_, childProv, __) {
                final balance = childProv.tokenBalance;
                return Column(
                  children: [
                    Container(
                      width: 200, height: 200,
                      decoration: const BoxDecoration(
                        color: AppColors.softBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('$balance',
                            style: const TextStyle(
                              fontSize:   48,
                              fontWeight: FontWeight.bold,
                              color:      AppColors.darkGray,
                            )),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tokens Available',
                        style: TextStyle(
                          fontSize:   16,
                          fontWeight: FontWeight.w600,
                          color:      AppColors.darkGray,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      balance >= 20
                          ? 'Great job! You have enough tokens!'
                          : 'Complete tasks to earn more tokens!',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.darkGray),
                    ),
                  ],
                );
              },
            ),

            const Spacer(),

            // task summary
            Consumer<TaskProvider>(
              builder: (_, taskProv, __) {
                final completed  = taskProv.tasks
                    .where((t) => t.isCompleted).length;
                final total      = taskProv.tasks.length;
                final tokensToday = taskProv.tasks
                    .where((t) => t.isCompleted)
                    .fold(0, (sum, t) => sum + t.tokensEarned);

                return Container(
                  margin:  const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:        AppColors.warmBeige,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.stars,
                          color: AppColors.sageGreen, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '$completed / $total tasks done today',
                        style: const TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+$tokensToday tokens earned today',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.darkGray),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}