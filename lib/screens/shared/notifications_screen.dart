import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _db = FirestoreService();

  String _fmt(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _onTap(AppNotification n) async {
    if (!n.isRead) await _db.markNotificationRead(n.notificationId);
    if (!mounted) return;

    final event = await _db.getEventById(n.eventId);
    if (event == null) return;
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event);
  }

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.userId ?? '';

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
                  const Expanded(
                    child: Text('Notifications',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        )),
                  ),
                  GestureDetector(
                    onTap: () => _db.markAllNotificationsRead(userId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Mark all read',
                          style: TextStyle(
                              fontSize: 11, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<List<AppNotification>>(
                stream: _db.streamNotifications(userId),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        color: AppColors.sageGreen));
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none,
                                color: AppColors.dustyGray, size: 60),
                            SizedBox(height: 16),
                            Text('No notifications yet.',
                                style: TextStyle(
                                    color: AppColors.darkGray)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final n = list[i];
                      return GestureDetector(
                        onTap: () => _onTap(n),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.cream
                                : AppColors.warmBeige,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: n.isRead
                                  ? AppColors.dustyGray.withOpacity(0.3)
                                  : AppColors.sageGreen.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: n.isRead
                                      ? AppColors.dustyGray.withOpacity(0.2)
                                      : AppColors.sageGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications,
                                  color: n.isRead
                                      ? AppColors.dustyGray
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.message,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: n.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_fmt(n.timestamp),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.dustyGray,
                                        )),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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