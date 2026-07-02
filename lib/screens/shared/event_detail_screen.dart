import 'package:flutter/material.dart';
import '../../models/overstimulation_event.dart';
import '../../models/event_note.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _noteController = TextEditingController();
  final _db             = FirestoreService();

  OverstimulationEvent? _event;
  List<EventNote>       _notes   = [];
  bool                  _loading = true;
  bool                  _saving  = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    _event = ModalRoute.of(context)!.settings.arguments
    as OverstimulationEvent?;
    if (_event == null) return;
    final notes = await _db.getNotes(_event!.eventId);
    if (mounted) setState(() { _notes = notes; _loading = false; });
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty || _event == null) return;
    setState(() => _saving = true);

    final note = EventNote(
      noteId:    '',
      eventId:   _event!.eventId,
      content:   _noteController.text.trim(),
      timestamp: DateTime.now(),
    );
    await _db.addNote(note);
    _noteController.clear();

    final notes = await _db.getNotes(_event!.eventId);
    if (mounted) setState(() { _notes = notes; _saving = false; });
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _noteController.dispose();
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
                  const Text('Event Details',
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
                  : _event == null
                  ? const Center(child: Text('Event not found.'))
                  : ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // event info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _event!.eventType == 'child-initiated'
                          ? AppColors.warmBeige
                          : AppColors.softBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(
                              _event!.eventType == 'child-initiated'
                                  ? Icons.child_care : Icons.edit,
                              color: AppColors.darkGray, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _event!.eventType == 'child-initiated'
                                ? 'Child Initiated'
                                : 'Manually Logged',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(_fmt(_event!.dateTime),
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.darkGray)),
                        if (_event!.audioStopped)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              '✓ Child stopped white noise manually',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.sageGreen,
                              ),
                            ),
                          ),
                        if (_event!.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Initial notes:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGray,
                              )),
                          Text(_event!.notes,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkGray,
                              )),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // notes
                  const Text('Notes',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 10),

                  if (_notes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lavender,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('No notes yet. Add one below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.darkGray)),
                    )
                  else
                    ..._notes.map((note) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.dustyGray
                                .withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(note.content,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGray,
                              )),
                          const SizedBox(height: 6),
                          Text(_fmt(note.timestamp),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.dustyGray,
                              )),
                        ],
                      ),
                    )),
                  const SizedBox(height: 20),

                  // add note
                  const Text('Add Note',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines:   3,
                    decoration: InputDecoration(
                      hintText:
                      'Write a note about this event...',
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
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saving ? null : _addNote,
                    child: _saving
                        ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2))
                        : const Text('Save Note'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}