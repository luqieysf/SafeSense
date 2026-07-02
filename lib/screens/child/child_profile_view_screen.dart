import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/child_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class ChildProfileViewScreen extends StatelessWidget {
  const ChildProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final child = Provider.of<ChildProvider>(context).childProfile;

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
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.darkGray, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('My Profile',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                  const Spacer(),
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
              child: child == null
                  ? const Center(child: Text('No profile found.'))
                  : ListView(
                padding: const EdgeInsets.all(20),
                children: [

                  // avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.softBlue,
                      backgroundImage: child.profileImageUrl.isNotEmpty
                          ? NetworkImage(child.profileImageUrl)
                          : null,
                      child: child.profileImageUrl.isEmpty
                          ? const Icon(Icons.person,
                          color: AppColors.darkGray, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(child.name,
                        style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        )),
                  ),
                  const SizedBox(height: 24),

                  _InfoCard(
                    label: 'Token Balance',
                    value: '${child.tokenBalance} tokens',
                    color: AppColors.softBlue,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'Noise Sensitivity',
                    value: child.noiseSensitivity.toUpperCase(),
                    color: AppColors.pastelTeal,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'Light Sensitivity',
                    value: child.lightSensitivity.toUpperCase(),
                    color: AppColors.lavender,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'Language',
                    value: child.language,
                    color: AppColors.warmBeige,
                  ),
                  const SizedBox(height: 24),

                  // calming audio settings
                  const Divider(color: AppColors.dustyGray),
                  const SizedBox(height: 16),
                  const Text('Calming Audio',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 8),
                  const Text(
                    'A caregiver or parent can set a custom '
                        'calming sound that plays when you press '
                        'the overwhelmed button.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.childAudio),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pastelTeal,
                      foregroundColor: AppColors.darkGray,
                    ),
                    icon: const Icon(Icons.music_note),
                    label: const Text('Manage Calming Audio'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value;
  final Color  color;

  const _InfoCard({
    required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(15)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: AppColors.darkGray)),
        Text(value, style: const TextStyle(
            fontSize: 14, color: AppColors.darkGray)),
      ],
    ),
  );
}