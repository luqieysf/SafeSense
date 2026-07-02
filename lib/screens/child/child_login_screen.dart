import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/child_provider.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_pinController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit PIN.')),
      );
      return;
    }
    final child   = Provider.of<ChildProvider>(context, listen: false);
    final success = await child.loginWithPin(_pinController.text.trim());
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.childHome);
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height
                    - MediaQuery.of(context).padding.top
                    - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // ── Back button ──────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.roleSelection),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.darkGray, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // logo
                    const Center(
                      child: Icon(Icons.favorite,
                          color: AppColors.darkGray, size: 60),
                    ),
                    const SizedBox(height: 20),

                    const Text('SafeSense',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        )),
                    const SizedBox(height: 6),

                    const Text('Child Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppColors.sageGreen,
                        )),
                    const SizedBox(height: 12),

                    const Text(
                      'Ask your parent or caregiver for your 6-digit PIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.darkGray),
                    ),
                    const SizedBox(height: 36),

                    // error message
                    Consumer<ChildProvider>(
                      builder: (_, child, __) {
                        if (child.errorMessage == null) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(child.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 13)),
                        );
                      },
                    ),

                    // PIN field
                    const Text('Enter PIN',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.darkGray,
                        )),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller:   _pinController,
                      keyboardType: TextInputType.number,
                      maxLength:    6,
                      textAlign:    TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                        color: AppColors.darkGray,
                      ),
                      decoration: const InputDecoration(
                        hintText:    '000000',
                        counterText: '',
                        hintStyle:   TextStyle(
                          letterSpacing: 12,
                          color: AppColors.dustyGray,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // login button
                    Consumer<ChildProvider>(
                      builder: (_, child, __) => ElevatedButton(
                        onPressed: child.isLoading ? null : _login,
                        child: child.isLoading
                            ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Text('Enter App'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Your parent sets up this app and gives you the PIN.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.darkGray),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}