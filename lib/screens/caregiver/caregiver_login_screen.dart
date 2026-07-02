import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class CaregiverLoginScreen extends StatefulWidget {
  const CaregiverLoginScreen({super.key});

  @override
  State<CaregiverLoginScreen> createState() => _CaregiverLoginScreenState();
}

class _CaregiverLoginScreenState extends State<CaregiverLoginScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool  _obscure          = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
        _emailController.text, _passwordController.text);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.caregiverDashboard);
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
            colors: [AppColors.pastelTeal, AppColors.lavender],
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      // ── Back button ──────────────────────────────────────────────────────
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
                      const SizedBox(height: 20),
                      const Center(
                        child: Icon(Icons.favorite_border,
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
                      const Text('Caregiver Portal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.sageGreen,
                          )),
                      const SizedBox(height: 36),

                      Consumer<AuthProvider>(
                        builder: (_, auth, __) {
                          if (auth.errorMessage == null) {
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
                            child: Text(auth.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.red.shade700, fontSize: 13)),
                          );
                        },
                      ),

                      const Text('Email Address',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: AppColors.darkGray,
                          )),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller:   _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: 'Enter your email'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email required';
                          if (!v.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      const Text('Password',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: AppColors.darkGray,
                          )),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller:  _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText:   'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.dustyGray,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password required';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading
                              ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.caregiverRegister),
                          child: const Text.rich(TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                                fontSize: 13, color: AppColors.darkGray),
                            children: [
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sageGreen,
                                ),
                              ),
                            ],
                          )),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
