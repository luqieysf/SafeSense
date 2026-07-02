import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ParentRegisterScreen extends StatefulWidget {
  const ParentRegisterScreen({super.key});

  @override
  State<ParentRegisterScreen> createState() =>
      _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<ParentRegisterScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _nameController      = TextEditingController();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _confirmController   = TextEditingController();
  bool  _obscure             = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth    = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      name:     _nameController.text,
      email:    _emailController.text,
      password: _passwordController.text,
      role:     'parent',
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.parentDashboard);
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // back
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
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

                  const Text('Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 6),
                  const Text('Parent Registration',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14, color: AppColors.sageGreen,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 32),

                  // error
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

                  _buildLabel('Full Name'),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Your full name'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Email Address'),
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
                  const SizedBox(height: 16),

                  _buildLabel('Password'),
                  TextFormField(
                    controller:  _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText:   'At least 6 characters',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
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
                  const SizedBox(height: 16),

                  _buildLabel('Confirm Password'),
                  TextFormField(
                    controller:  _confirmController,
                    obscureText: _obscure,
                    decoration: const InputDecoration(
                        hintText: 'Repeat your password'),
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      child: auth.isLoading
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        )),
  );
}
