import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/child_provider.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // check child session first (stored in SharedPreferences)
    final childProv = Provider.of<ChildProvider>(context, listen: false);
    final hasChild  = await childProv.restoreChildSession();
    if (!mounted) return;

    if (hasChild) {
      Navigator.pushReplacementNamed(context, AppRoutes.childHome);
      return;
    }

    // check parent / caregiver session (Firebase Auth)
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.restoreSession();
    if (!mounted) return;

    if (auth.isLoggedIn) {
      switch (auth.role) {
        case 'parent':
          Navigator.pushReplacementNamed(context, AppRoutes.parentDashboard);
          break;
        case 'caregiver':
          Navigator.pushReplacementNamed(context, AppRoutes.caregiverDashboard);
          break;
        default:
          Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.softBlue, AppColors.lavender],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: AppColors.darkGray, size: 60),
              SizedBox(height: 20),
              Text('SafeSense',
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  )),
              SizedBox(height: 8),
              Text('Calm. Safe. Connected.',
                  style: TextStyle(fontSize: 14, color: AppColors.darkGray)),
              SizedBox(height: 48),
              CircularProgressIndicator(
                  color: AppColors.sageGreen, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}