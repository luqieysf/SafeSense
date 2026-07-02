import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _storage   = StorageService();
  final _db        = FirestoreService();
  bool  _uploading = false;

  Future<void> _changePicture() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) return;
    setState(() => _uploading = true);

    final url = await _storage
        .pickAndUploadUserImage(auth.currentUser!.userId);
    if (url != null) {
      await _db.updateUserProfile(auth.currentUser!.userId,
          profileImageUrl: url);
      await auth.restoreSession();
    }
    if (mounted) setState(() => _uploading = false);
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
                  const Text('My Profile',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                ],
              ),
            ),

            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                final user = auth.currentUser;
                if (user == null) {
                  return const Expanded(
                      child: Center(child: Text('Not logged in.')));
                }
                return Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [

                      // profile picture
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.softBlue,
                              backgroundImage: user.profileImageUrl.isNotEmpty
                                  ? NetworkImage(user.profileImageUrl)
                                  : null,
                              child: user.profileImageUrl.isEmpty
                                  ? const Icon(Icons.person,
                                  color: AppColors.darkGray, size: 60)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: _uploading ? null : _changePicture,
                                child: Container(
                                  width: 34, height: 34,
                                  decoration: const BoxDecoration(
                                    color: AppColors.sageGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _uploading
                                      ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _InfoCard(label: 'Name',
                          value: user.name,  color: AppColors.warmBeige),
                      const SizedBox(height: 12),
                      _InfoCard(label: 'Email',
                          value: user.email, color: AppColors.softBlue),
                      const SizedBox(height: 12),
                      _InfoCard(label: 'Role',
                          value: user.role.toUpperCase(),
                          color: AppColors.pastelTeal),
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
        Flexible(child: Text(value,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 14, color: AppColors.darkGray))),
      ],
    ),
  );
}