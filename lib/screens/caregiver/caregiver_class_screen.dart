import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CaregiverClassScreen extends StatelessWidget {
  const CaregiverClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Text('Class management is no longer available.',
              style: TextStyle(color: AppColors.darkGray)),
        ),
      ),
    );
  }
}
