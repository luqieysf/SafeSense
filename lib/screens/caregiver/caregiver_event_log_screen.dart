import 'package:flutter/material.dart';
import '../../models/overstimulation_event.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class CaregiverEventLogScreen extends StatefulWidget {
  const CaregiverEventLogScreen({super.key});

  @override
  State<CaregiverEventLogScreen> createState() => _CaregiverEventLogScreenState();
}

class _CaregiverEventLogScreenState extends State<CaregiverEventLogScreen> {
  final _notesController = TextEditingController();
  final _db              = FirestoreService();

  DateTime  _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool      _isSaving     = false;
  String?   _childId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _childId = ModalRoute.of(context)!.settings.arguments as String?;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _selectedDate,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (_childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No child selected.')));
      return;
    }

    setState(() => _isSaving = true);

    final eventDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    try {
      await _db.addEvent(OverstimulationEvent(
        eventId:      '',
        childId:      _childId!,
        eventType:    'manual',
        dateTime:     eventDateTime,
        notes:        _notesController.text.trim(),
        audioStopped: false,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event logged!')));
      _notesController.clear();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isSaving = false);
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
                  const Text('Log Event',
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
                    const Text('Date',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.darkGray,
                        )),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.darkGray),
                            ),
                            const Icon(Icons.calendar_today,
                                color: AppColors.darkGray, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text('Time',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.darkGray,
                        )),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.pastelTeal,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedTime.format(context),
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.darkGray)),
                            const Icon(Icons.access_time,
                                color: AppColors.darkGray, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text('Notes',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.darkGray,
                        )),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines:   5,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about the incident...',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppColors.sageGreen, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppColors.sageGreen, width: 2),
                        ),
                        fillColor: AppColors.cream,
                        filled:    true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Event'),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lavender,
                        foregroundColor: AppColors.darkGray,
                        minimumSize:     const Size(double.infinity, 50),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
