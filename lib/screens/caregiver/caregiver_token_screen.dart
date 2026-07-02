import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CaregiverTokenScreen extends StatelessWidget {
  const CaregiverTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Text('Token management is no longer available for caregivers.',
              style: TextStyle(color: AppColors.darkGray)),
        ),
      ),
    );
  }
}
