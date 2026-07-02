import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/child_profile.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/notification_banner_overlay.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState
    extends State<ParentDashboardScreen> {
  final _db = FirestoreService();
  List<ChildProfile> _children = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ids  = auth.currentUser?.linkedChildIds ?? [];
    final list = await _db.getChildrenForUser(ids);
    if (mounted) setState(() { _children = list; _loading = false; });
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Log Out'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Log Out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      if (!mounted) return;
      await Provider.of<AuthProvider>(context, listen: false).logout();
      Provider.of<ChildProvider>(context, listen: false).clearChild();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false)
        .currentUser?.userId ?? '';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: NotificationBannerOverlay(
        userId: userId,
        child: SafeArea(
          child: Column(
            children: [
              // header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dashboard',
                        style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        )),
                    Row(
                      children: [
                        NotificationBell(userId: userId),
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: AppColors.darkGray),
                          onPressed: _logout,
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(
                    color: AppColors.sageGreen))
                    : RefreshIndicator(
                  onRefresh: _loadChildren,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [

                      // My Children card
                      _DashCard(
                        title:   'My Children',
                        subtitle: '${_children.length} child${_children.length == 1 ? '' : 'ren'}',
                        icon:    Icons.people,
                        color:   AppColors.lavender,
                        height:  160,
                        onTap:   () => Navigator.pushNamed(
                            context, AppRoutes.parentChildren)
                            .then((_) => _loadChildren()),
                      ),
                      const SizedBox(height: 12),

                      // Add Child button
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.parentAddChild)
                            .then((_) => _loadChildren()),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Add Child',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Create Task card
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.parentCreateTask),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.pastelTeal,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_task,
                                  color: AppColors.darkGray, size: 28),
                              SizedBox(width: 10),
                              Text('Create Task',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGray,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Small cards row
                      Row(children: [
                        Expanded(
                          child: _DashCard(
                            title:   'Recent Events',
                            subtitle: 'View log',
                            icon:    Icons.history,
                            color:   AppColors.pastelTeal,
                            height:  140,
                            onTap:   () => Navigator.pushNamed(
                                context, AppRoutes.eventList),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _DashCard(
                            title:   'Generate Report',
                            subtitle: 'Monthly view',
                            icon:    Icons.bar_chart,
                            color:   AppColors.softBlue,
                            height:  140,
                            onTap:   () => Navigator.pushNamed(
                                context, AppRoutes.report),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // children tiles
                      if (_children.isNotEmpty) ...[
                        const Text('Your Children',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            )),
                        const SizedBox(height: 10),
                        ..._children.map((c) => _ChildTile(
                          child: c,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.parentEditChild,
                              arguments: c)
                              .then((_) => _loadChildren()),
                        )),
                      ],
                    ],
                  ),
                ),
              ),

              // bottom nav
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(
                      color: AppColors.dustyGray, width: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BottomIcon(icon: Icons.home,
                        color: AppColors.softBlue, onTap: () {}),
                    _BottomIcon(
                      icon:  Icons.person,
                      color: AppColors.sageGreen,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.userProfile),
                    ),
                    _BottomIcon(
                      icon:  Icons.add_circle_outline,
                      color: AppColors.pastelTeal,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.parentEventSelectChild),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ─────────────────────────────────────────────────────────
class _DashCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final double height;
  final VoidCallback onTap;

  const _DashCard({
    required this.title, required this.subtitle,
    required this.icon,  required this.color,
    required this.height, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: height,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.darkGray, size: 34),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold,
              color: AppColors.darkGray)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(
              fontSize: 12, color: AppColors.darkGray)),
        ],
      ),
    ),
  );
}

class _ChildTile extends StatelessWidget {
  final ChildProfile child;
  final VoidCallback onTap;
  const _ChildTile({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.warmBeige,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.softBlue,
            backgroundImage: child.profileImageUrl.isNotEmpty
                ? NetworkImage(child.profileImageUrl) : null,
            child: child.profileImageUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.darkGray) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(child.name, style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold,
                  color: AppColors.darkGray)),
              Text('Tokens: ${child.tokenBalance} • PIN: ${child.pin}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.darkGray)),
            ],
          )),
          const Icon(Icons.edit, color: AppColors.sageGreen, size: 18),
        ],
      ),
    ),
  );
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BottomIcon({
    required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: AppColors.darkGray, size: 24),
    ),
  );
}
