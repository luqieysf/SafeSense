import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class NotificationBannerOverlay extends StatefulWidget {
  final String userId;
  final Widget child;
  const NotificationBannerOverlay({
    super.key, required this.userId, required this.child});

  @override
  State<NotificationBannerOverlay> createState() =>
      _NotificationBannerOverlayState();
}

class _NotificationBannerOverlayState
    extends State<NotificationBannerOverlay> {
  final _db = FirestoreService();
  final Set<String> _seenIds   = {};
  bool _initialized            = false;
  AppNotification? _banner;

  void _handle(List<AppNotification> list) {
    if (!_initialized) {
      // mark everything already present as "seen" so we don't
      // banner old notifications on first load
      _seenIds.addAll(list.map((n) => n.notificationId));
      _initialized = true;
      return;
    }

    final newOnes = list.where((n) =>
    !_seenIds.contains(n.notificationId) && !n.isRead).toList();

    if (newOnes.isNotEmpty) {
      final newest = newOnes.first; // already sorted newest first
      _seenIds.add(newest.notificationId);
      if (mounted) setState(() => _banner = newest);

      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _banner?.notificationId == newest.notificationId) {
          setState(() => _banner = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<AppNotification>>(
          stream: _db.streamNotifications(widget.userId),
          builder: (context, snap) {
            if (snap.hasData) {
              WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _handle(snap.data!));
            }
            return widget.child;
          },
        ),
        if (_banner != null)
          Positioned(
            top: 12, left: 16, right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  setState(() => _banner = null);
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
                child: Material(
                  borderRadius: BorderRadius.circular(15),
                  elevation:    6,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warmBeige,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active,
                            color: AppColors.darkGray),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _banner!.message,
                            style: const TextStyle(
                              color:      AppColors.darkGray,
                              fontWeight: FontWeight.w600,
                              fontSize:   13,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _banner = null),
                          child: const Icon(Icons.close,
                              size: 18, color: AppColors.darkGray),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}