import 'package:flutter/material.dart';
import '../../models/child_profile.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ParentEditChildScreen extends StatefulWidget {
  const ParentEditChildScreen({super.key});

  @override
  State<ParentEditChildScreen> createState() =>
      _ParentEditChildScreenState();
}

class _ParentEditChildScreenState
    extends State<ParentEditChildScreen> {
  final _nameController = TextEditingController();
  final _db             = FirestoreService();
  final _storage        = StorageService();

  ChildProfile? _child;
  String _noiseSensitivity = 'low';
  String _lightSensitivity = 'low';
  String _language         = 'English';
  bool   _isSaving         = false;
  bool   _uploading        = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    _child = ModalRoute.of(context)!.settings.arguments as ChildProfile?;
    if (_child == null) return;
    setState(() {
      _nameController.text  = _child!.name;
      _noiseSensitivity     = _child!.noiseSensitivity;
      _lightSensitivity     = _child!.lightSensitivity;
      _language             = _child!.language;
    });
  }

  Future<void> _changePicture() async {
    if (_child == null) return;
    setState(() => _uploading = true);
    final url = await _storage.pickAndUploadChildImage(_child!.childId);
    if (url != null) {
      await _db.updateChildImageUrl(_child!.childId, url);
      setState(() => _child = _child!.copyWith(profileImageUrl: url));
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _save() async {
    if (_child == null || _nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    final updated = _child!.copyWith(
      name:             _nameController.text.trim(),
      noiseSensitivity: _noiseSensitivity,
      lightSensitivity: _lightSensitivity,
      language:         _language,
    );

    try {
      await _db.saveChildProfile(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                  const Text('Edit Child Profile',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                ],
              ),
            ),

            Expanded(
              child: _child == null
                  ? const Center(child: Text('Child not found.'))
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // profile picture
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.softBlue,
                            backgroundImage:
                            _child!.profileImageUrl.isNotEmpty
                                ? NetworkImage(_child!.profileImageUrl)
                                : null,
                            child: _child!.profileImageUrl.isEmpty
                                ? const Icon(Icons.person,
                                color: AppColors.darkGray, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: _uploading ? null : _changePicture,
                              child: Container(
                                width: 32, height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.sageGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: _uploading
                                    ? const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // PIN badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.lavender,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'PIN: ${_child!.pin}',
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold,
                            letterSpacing: 4, color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _label('Child Name'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          hintText: "Child's name"),
                    ),
                    const SizedBox(height: 16),

                    _label('Noise Sensitivity'),
                    _dropdown(value: _noiseSensitivity,
                        color: AppColors.softBlue,
                        onChanged: (v) =>
                            setState(() => _noiseSensitivity = v!)),
                    const SizedBox(height: 16),

                    _label('Light Sensitivity'),
                    _dropdown(value: _lightSensitivity,
                        color: AppColors.pastelTeal,
                        onChanged: (v) =>
                            setState(() => _lightSensitivity = v!)),
                    const SizedBox(height: 16),

                    _label('Language'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _language, isExpanded: true,
                          dropdownColor: AppColors.sageGreen,
                          onChanged: (v) => setState(() => _language = v!),
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

                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text('Save Changes'),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.handoverNotes,
                          arguments: _child),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lavender,
                        foregroundColor: AppColors.darkGray,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.sticky_note_2_outlined),
                      label: const Text('Handover Notes'),
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
    required void Function(String?) onChanged,
  }) => Container(
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(15)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, isExpanded: true, dropdownColor: color,
        onChanged: onChanged,
        items: ['low', 'medium', 'high'].map((v) => DropdownMenuItem(
          value: v,
          child: Text(v, style: const TextStyle(color: AppColors.darkGray)),
        )).toList(),
      ),
    ),
  );
}
