import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/child_profile.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class ParentAddChildScreen extends StatefulWidget {
  const ParentAddChildScreen({super.key});

  @override
  State<ParentAddChildScreen> createState() =>
      _ParentAddChildScreenState();
}

class _ParentAddChildScreenState
    extends State<ParentAddChildScreen> {
  final _nameController = TextEditingController();
  final _db             = FirestoreService();

  String  _noiseSensitivity = 'low';
  String  _lightSensitivity = 'low';
  String  _language         = 'English';
  String? _generatedPin;
  bool    _isSaving         = false;
  bool    _saved            = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generatePin() =>
      List.generate(6, (_) => Random().nextInt(10)).join();

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a child name.')));
      return;
    }
    setState(() => _isSaving = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final pin  = _generatePin();

    final profile = ChildProfile(
      childId:          '',
      name:             _nameController.text.trim(),
      noiseSensitivity: _noiseSensitivity,
      lightSensitivity: _lightSensitivity,
      tokenBalance:     25,
      language:         _language,
      deviceId:         '',
      pin:              pin,
      linkedUserIds:    [auth.currentUser!.userId],
      caregiverEmail:   auth.currentUser!.email,
    );

    try {
      final newId = await _db.createChildProfile(profile);
      await _db.linkUserToChild(newId, auth.currentUser!.userId);
      await auth.restoreSession();
      setState(() { _generatedPin = pin; _isSaving = false; _saved = true; });
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
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
                  const Text('Add Child Profile',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // PIN display (shown after save)
                    if (_saved && _generatedPin != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 36),
                            const SizedBox(height: 8),
                            const Text('Child Profile Created!',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                            const SizedBox(height: 8),
                            const Text(
                              'Share this PIN with the child\'s device:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _generatedPin!,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 10,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Write this down!\n'
                                  'The child enters this PIN to log in.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _label('Child Name'),
                    TextFormField(
                      controller: _nameController,
                      enabled:    !_saved,
                      decoration: const InputDecoration(
                          hintText: "Child's full name"),
                    ),
                    const SizedBox(height: 16),

                    _label('Noise Sensitivity'),
                    _dropdown(value: _noiseSensitivity,
                        color: AppColors.softBlue, enabled: !_saved,
                        onChanged: (v) =>
                            setState(() => _noiseSensitivity = v!)),
                    const SizedBox(height: 16),

                    _label('Light Sensitivity'),
                    _dropdown(value: _lightSensitivity,
                        color: AppColors.pastelTeal, enabled: !_saved,
                        onChanged: (v) =>
                            setState(() => _lightSensitivity = v!)),
                    const SizedBox(height: 16),

                    _label('Language Preference'),
                    Container(
                      decoration: BoxDecoration(
                        color: _saved
                            ? AppColors.dustyGray.withOpacity(0.2)
                            : AppColors.sageGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _language, isExpanded: true,
                          dropdownColor: AppColors.sageGreen,
                          onChanged: _saved
                              ? null
                              : (v) => setState(() => _language = v!),
                          items: ['English', 'Bahasa Malaysia']
                              .map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(l,
                                style: const TextStyle(
                                    color: AppColors.darkGray)),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!_saved)
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Text('Save & Generate PIN'),
                      ),
                    if (_saved)
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.darkGray)),
  );

  Widget _dropdown({
    required String value, required Color color,
    required bool enabled, required void Function(String?) onChanged,
  }) => Container(
    decoration: BoxDecoration(
      color: enabled ? color : AppColors.dustyGray.withOpacity(0.2),
      borderRadius: BorderRadius.circular(15),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, isExpanded: true, dropdownColor: color,
        onChanged: enabled ? onChanged : null,
        items: ['low', 'medium', 'high'].map((v) => DropdownMenuItem(
          value: v,
          child: Text(v, style: const TextStyle(color: AppColors.darkGray)),
        )).toList(),
      ),
    ),
  );
}
