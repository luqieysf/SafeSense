import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CaregiverCreateTaskScreen extends StatelessWidget {
  const CaregiverCreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Text('Task creation is no longer available for caregivers.',
              style: TextStyle(color: AppColors.darkGray)),
        ),
      ),
    );
  }
}
