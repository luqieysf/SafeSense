import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.softBlue, AppColors.lavender],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // icon
                const Icon(
                  Icons.favorite,
                  color: AppColors.darkGray,
                  size: 52,
                ),
                const SizedBox(height: 16),

                // title
                const Text(
                  'Welcome to\nSafeSense',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),

                // subtitle
                const Text(
                  'Who are you?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 52),

                // Child
                _RoleCard(
                  icon:    Icons.child_care,
                  label:   'Child',
                  color:   AppColors.warmBeige,
                  onTap:   () => Navigator.pushNamed(
                      context, AppRoutes.childLogin),
                ),
                const SizedBox(height: 16),

                // Parent
                _RoleCard(
                  icon:    Icons.favorite_border,
                  label:   'Parent',
                  color:   AppColors.sageGreen,
                  onTap:   () => Navigator.pushNamed(
                      context, AppRoutes.parentLogin),
                ),
                const SizedBox(height: 16),

                // Caregiver
                _RoleCard(
                  icon:    Icons.school,
                  label:   'Caregiver',
                  color:   AppColors.pastelTeal,
                  onTap:   () => Navigator.pushNamed(
                      context, AppRoutes.caregiverLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Role Card Widget ────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color:         color,
          borderRadius:  BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.darkGray, size: 30),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize:   20,
                fontWeight: FontWeight.bold,
                color:      AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}