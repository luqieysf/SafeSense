import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/child_profile.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';


class CaregiverChildViewScreen extends StatefulWidget {
  const CaregiverChildViewScreen({super.key});

  @override
  State<CaregiverChildViewScreen> createState() =>
      _CaregiverChildViewScreenState();
}

class _CaregiverChildViewScreenState extends State<CaregiverChildViewScreen> {
  final _db = FirestoreService();

  ChildProfile? _child;
  String?        _linkedUserIdsKey;
  Future<String>? _parentEmailFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _child =
    ModalRoute.of(context)!.settings.arguments as ChildProfile?;
  }

  // The stored `caregiverEmail` snapshot on the child document can be blank
  // (older data, or a child linked without going through the add-child flow)
  // or stale (parent changed their email). Resolve the live parent account
  // from linkedUserIds instead, falling back to the stored snapshot.
  Future<String> _resolveParentEmail(ChildProfile child) async {
    for (final uid in child.linkedUserIds) {
      final user = await _db.getUserAccount(uid);
      if (user != null && user.role == 'parent' && user.email.isNotEmpty) {
        return user.email;
      }
    }
    return child.caregiverEmail;
  }

  Future<String> _emailFutureFor(ChildProfile child) {
    final key = child.linkedUserIds.join(',');
    if (_linkedUserIdsKey != key || _parentEmailFuture == null) {
      _linkedUserIdsKey  = key;
      _parentEmailFuture = _resolveParentEmail(child);
    }
    return _parentEmailFuture!;
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
                  const Text('Child Profile',
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
              child: _child == null
                  ? const Center(child: Text('Child not found.'))
                  : StreamBuilder<ChildProfile?>(
                stream: _db.streamChildProfile(_child!.childId),
                builder: (_, snap) {
                  final child = snap.data ?? _child!;
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [

                      // avatar
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.softBlue,
                          backgroundImage:
                          child.profileImageUrl.isNotEmpty
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            )),
                      ),
                      const SizedBox(height: 24),

                      _InfoCard(label: 'Token Balance',
                          value: '${child.tokenBalance} tokens',
                          color: AppColors.softBlue),
                      const SizedBox(height: 12),
                      _InfoCard(label: 'Noise Sensitivity',
                          value: child.noiseSensitivity.toUpperCase(),
                          color: AppColors.pastelTeal),
                      const SizedBox(height: 12),
                      _InfoCard(label: 'Light Sensitivity',
                          value: child.lightSensitivity.toUpperCase(),
                          color: AppColors.lavender),
                      const SizedBox(height: 12),
                      _InfoCard(label: 'Language',
                          value: child.language,
                          color: AppColors.warmBeige),
                      const SizedBox(height: 20),

                      // parent contact
                      const Text('Parent Contact',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          )),
                      const SizedBox(height: 8),
                      FutureBuilder<String>(
                        future: _emailFutureFor(child),
                        builder: (_, emailSnap) {
                          final loading = emailSnap.connectionState ==
                              ConnectionState.waiting;
                          final email   = emailSnap.data ?? '';
                          final display = loading
                              ? 'Loading...'
                              : (email.isNotEmpty ? email : 'Not available');

                          return GestureDetector(
                            onTap: email.isEmpty ? null : () {
                              Clipboard.setData(ClipboardData(text: email));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Email copied!')));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.sageGreen,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.email,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text('Parent Email',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            )),
                                        Text(
                                          display,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (email.isNotEmpty)
                                    const Icon(Icons.copy,
                                        color: Colors.white70, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // today's tasks (read-only)
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.caregiverChildTasks,
                            arguments: child),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pastelTeal,
                          foregroundColor: AppColors.darkGray,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        icon: const Icon(Icons.task_alt),
                        label: const Text('View Routine Tasks'),
                      ),
                      const SizedBox(height: 12),

                      // handover notes
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.handoverNotes,
                            arguments: child),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lavender,
                          foregroundColor: AppColors.darkGray,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        icon: const Icon(Icons.sticky_note_2_outlined),
                        label: const Text('Handover Notes'),
                      ),
                      const SizedBox(height: 40),
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
