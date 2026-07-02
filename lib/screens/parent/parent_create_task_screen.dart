import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/routine_task.dart';
import '../../models/child_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class ParentCreateTaskScreen extends StatefulWidget {
  const ParentCreateTaskScreen({super.key});

  @override
  State<ParentCreateTaskScreen> createState() =>
      _ParentCreateTaskScreenState();
}

class _ParentCreateTaskScreenState
    extends State<ParentCreateTaskScreen> {
  final _taskNameCtrl  = TextEditingController();
  final _tokenCtrl     = TextEditingController(text: '1');
  final _db            = FirestoreService();

  List<ChildProfile> _children       = [];
  ChildProfile?       _selectedChild;

  String?    _selectedIcon  = '🍳';
  TimeOfDay? _scheduledTime;
  bool       _reminder      = false;
  bool       _isSaving      = false;
  bool       _loading       = true;
  bool       _isRecurring   = true; // true = "Everyday Task"

  final List<String> _icons = [
    '🍳', '🪥', '👕', '📚', '🎨', '🛌',
    '🏃', '🧹', '🍎', '🚿', '👟', '📖',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ids  = auth.currentUser?.linkedChildIds ?? [];
    final children = await _db.getChildrenForUser(ids);
    if (mounted) {
      setState(() {
        _children      = children;
        _selectedChild = children.isNotEmpty ? children.first : null;
        _loading       = false;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context,
        initialTime: _scheduledTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _scheduledTime = picked);
  }

  Future<void> _save() async {
    if (_taskNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a task name.')));
      return;
    }
    if (_selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a child.')));
      return;
    }

    final tokensEarned = int.tryParse(_tokenCtrl.text.trim()) ?? 1;

    setState(() => _isSaving = true);

    DateTime? scheduled;
    if (_scheduledTime != null) {
      final now = DateTime.now();
      scheduled = DateTime(now.year, now.month, now.day,
          _scheduledTime!.hour, _scheduledTime!.minute);
    }

    try {
      await _db.addTask(RoutineTask(
        taskId:        '',
        childId:       _selectedChild!.childId,
        taskName:      _taskNameCtrl.text.trim(),
        icon:          _selectedIcon ?? '📌',
        scheduledTime: scheduled,
        reminder:      _reminder,
        isCompleted:   false,
        tokensEarned:  tokensEarned,
        isRecurring:   _isRecurring,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isRecurring
              ? 'Everyday task created for ${_selectedChild!.name}!'
              : 'Task created for ${_selectedChild!.name}!')));
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
    _taskNameCtrl.dispose();
    _tokenCtrl.dispose();
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
                  const Text('Create Task',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(
                  color: AppColors.sageGreen))
                  : _children.isEmpty
                  ? const Center(
                  child: Text(
                    'No children linked yet.\n'
                        'Add a child from the dashboard first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGray),
                  ))
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── Task Name ─────────────────────────────────
                    _label('Task Name'),
                    TextFormField(
                      controller: _taskNameCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Enter task name'),
                    ),
                    const SizedBox(height: 16),

                    // ── Task Type ─────────────────────────────────
                    _label('Task Type'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TaskTypeOption(
                            icon:       Icons.repeat,
                            label:      'Everyday Task',
                            sublabel:   'Repeats daily',
                            selected:   _isRecurring,
                            onTap:      () =>
                                setState(() => _isRecurring = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TaskTypeOption(
                            icon:       Icons.looks_one_outlined,
                            label:      'Additional Task',
                            sublabel:   'One-time only',
                            selected:   !_isRecurring,
                            onTap:      () =>
                                setState(() => _isRecurring = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Token Reward ──────────────────────────────
                    _label('Token Reward'),
                    TextFormField(
                      controller:   _tokenCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Tokens earned on completion',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Icon ──────────────────────────────────────
                    _label('Task Icon'),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:    const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:   6,
                        mainAxisSpacing:  8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _icons.length,
                      itemBuilder: (_, i) {
                        final ico      = _icons[i];
                        final selected = _selectedIcon == ico;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedIcon = ico),
                          child: Container(
                            decoration: BoxDecoration(
                              color:  selected
                                  ? AppColors.sageGreen
                                  : AppColors.pastelTeal,
                              shape:  BoxShape.circle,
                              border: selected
                                  ? Border.all(
                                  color: AppColors.darkGray,
                                  width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(ico,
                                  style: const TextStyle(
                                      fontSize: 22)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Child selector ─────────────────────────────
                    _label('Select Child'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ChildProfile>(
                          value:         _selectedChild,
                          isExpanded:    true,
                          dropdownColor: AppColors.softBlue,
                          onChanged: (v) =>
                              setState(() => _selectedChild = v),
                          items: _children.map((c) =>
                              DropdownMenuItem(
                                value: c,
                                child: Text(c.name,
                                    style: const TextStyle(
                                        color: AppColors.darkGray)),
                              )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Scheduled Time ────────────────────────────
                    _label('Scheduled Time (optional)'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _scheduledTime == null
                                  ? 'Tap to set time'
                                  : _scheduledTime!.format(context),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkGray),
                            ),
                            const Icon(Icons.access_time,
                                color: AppColors.darkGray, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Reminder toggle ───────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.warmBeige,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Enable Reminder',
                              style: TextStyle(
                                fontSize:   14,
                                fontWeight: FontWeight.w500,
                                color:      AppColors.darkGray,
                              )),
                          Switch(
                            value:             _reminder,
                            activeColor:       AppColors.sageGreen,
                            inactiveThumbColor: AppColors.dustyGray,
                            onChanged: (v) =>
                                setState(() => _reminder = v),
                          ),
                        ],
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
                          : const Text('Save Task'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lavender,
                        foregroundColor: AppColors.darkGray,
                        minimumSize:
                        const Size(double.infinity, 50),
                      ),
                      child: const Text('Cancel'),
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
}

class _TaskTypeOption extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final String       sublabel;
  final bool         selected;
  final VoidCallback onTap;

  const _TaskTypeOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.sageGreen : AppColors.warmBeige,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: AppColors.darkGray, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Icon(icon,
              color: selected ? Colors.white : AppColors.darkGray),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppColors.darkGray,
              )),
          const SizedBox(height: 2),
          Text(sublabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? Colors.white.withOpacity(0.85)
                    : AppColors.darkGray,
              )),
        ],
      ),
    ),
  );
}
