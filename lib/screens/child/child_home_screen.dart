import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/child_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/child_profile.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  final FirestoreService _db = FirestoreService();

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!mounted) return;
      await Provider.of<ChildProvider>(context, listen: false).logoutChild();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childProv = Provider.of<ChildProvider>(context);
    final child     = childProv.childProfile;
    final name      = child?.name ?? 'Friend';
    final childId   = child?.childId ?? '';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [

            // header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SafeSense',
                      style: TextStyle(
                        fontSize:   20,
                        fontWeight: FontWeight.bold,
                        color:      AppColors.darkGray,
                      )),
                  Text('Hi, $name!',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.darkGray)),
                ],
              ),
            ),
            const Divider(color: AppColors.dustyGray, thickness: 1),

            const Spacer(),

            // big button
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.childAlert),
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  color:        AppColors.warmBeige,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.favorite,
                        color: AppColors.darkGray, size: 60),
                    SizedBox(height: 16),
                    Text("I'm Overwhelmed",
                        style: TextStyle(
                          fontSize:   20,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.darkGray,
                        )),
                    SizedBox(height: 8),
                    Text('Press for help',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.darkGray)),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // bottom nav
            const Divider(color: AppColors.dustyGray, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  _NavCircle(
                    icon:  Icons.bar_chart,
                    label: 'Routine',
                    color: AppColors.pastelTeal,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.childRoutine),
                  ),

                  // real-time token balance
                  StreamBuilder<ChildProfile?>(
                    stream: childId.isNotEmpty
                        ? _db.streamChildProfile(childId)
                        : const Stream.empty(),
                    builder: (_, snap) {
                      final balance = snap.data?.tokenBalance
                          ?? childProv.tokenBalance;
                      return _NavCircle(
                        label:   '$balance',
                        isToken: true,
                        color:   AppColors.softBlue,
                        onTap:   () => Navigator.pushNamed(
                            context, AppRoutes.childToken),
                      );
                    },
                  ),

                  _NavCircle(
                    icon:  Icons.person,
                    label: 'Profile',
                    color: AppColors.lavender,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.childProfileView),
                  ),

                  _NavCircle(
                    icon:  Icons.logout,
                    label: 'Logout',
                    color: AppColors.warmBeige,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCircle extends StatelessWidget {
  final IconData?    icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final bool         isToken;

  const _NavCircle({
    this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isToken = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: isToken
                ? Center(child: Text(label,
                style: const TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.bold,
                  color:      AppColors.darkGray,
                )))
                : Icon(icon, color: AppColors.darkGray, size: 26),
          ),
          const SizedBox(height: 4),
          Text(isToken ? 'Tokens' : label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.darkGray)),
        ],
      ),
    );
  }
}