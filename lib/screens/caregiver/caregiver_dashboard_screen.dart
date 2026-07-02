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

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final _db              = FirestoreService();
  List<ChildProfile> _children = [];
  bool               _loading  = true;

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

  Future<void> _linkChild() async {
    final pinCtrl = TextEditingController();
    final result  = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Link Child'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter the 6-digit PIN from the child\'s parent:'),
            const SizedBox(height: 12),
            TextField(
              controller:   pinCtrl,
              keyboardType: TextInputType.number,
              maxLength:    6,
              textAlign:    TextAlign.center,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  letterSpacing: 8),
              decoration: const InputDecoration(
                  counterText: '', hintText: '000000'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Link')),
        ],
      ),
    );

    if (result != true) return;
    final pin = pinCtrl.text.trim();
    if (pin.length < 6) return;

    final child = await _db.findChildByPin(pin);
    if (!mounted) return;

    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No child found with that PIN.')));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await _db.linkUserToChild(child.childId, auth.currentUser!.userId);
    await auth.restoreSession();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Linked to ${child.name}!')));
    _loadChildren();
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
                    Row(children: [
                      NotificationBell(userId: userId),
                      IconButton(
                        icon: const Icon(Icons.link,
                            color: AppColors.darkGray),
                        onPressed: _linkChild,
                        tooltip: 'Link Child',
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: AppColors.darkGray),
                        onPressed: _logout,
                        tooltip: 'Logout',
                      ),
                    ]),
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

                      // children list
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Linked Children',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGray,
                              )),
                          TextButton.icon(
                            onPressed: _linkChild,
                            icon:  const Icon(Icons.add,
                                color: AppColors.sageGreen, size: 18),
                            label: const Text('Link',
                                style: TextStyle(
                                    color: AppColors.sageGreen,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_children.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.warmBeige,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'No children linked yet.\n'
                                'Tap the 🔗 icon to link a child using their PIN.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.darkGray),
                          ),
                        )
                      else
                        ..._children.map((c) => _ChildTile(
                          child: c,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.caregiverChildView,
                              arguments: c),
                        )),
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
                          context, AppRoutes.caregiverEventSelectStudent),
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

// ── Reusable widgets ──────────────────────────────────────────────────────────
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
          Icon(icon, color: AppColors.darkGray, size: 32),
          const SizedBox(height: 8),
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
  Widget build(BuildContext context) {
    final now          = DateTime.now();
    final currentMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final showBadge    = child.lastEventMonth == currentMonth &&
        child.monthlyEventCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmBeige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.pastelTeal,
              backgroundImage: child.profileImageUrl.isNotEmpty
                  ? NetworkImage(child.profileImageUrl) : null,
              child: child.profileImageUrl.isEmpty
                  ? const Icon(Icons.person, color: AppColors.darkGray)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold,
                    color: AppColors.darkGray)),
                Text('Tokens: ${child.tokenBalance}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.darkGray)),
              ],
            )),
            if (showBadge)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${child.monthlyEventCount} this month',
                  style: const TextStyle(
                    fontSize: 10, color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.darkGray),
          ],
        ),
      ),
    );
  }
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
