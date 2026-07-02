import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/child_profile.dart';
import '../../models/handover_note.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class HandoverNotesScreen extends StatefulWidget {
  const HandoverNotesScreen({super.key});

  @override
  State<HandoverNotesScreen> createState() => _HandoverNotesScreenState();
}

class _HandoverNotesScreenState extends State<HandoverNotesScreen> {
  final _db             = FirestoreService();
  final _noteController = TextEditingController();

  ChildProfile? _child;
  bool          _posting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _child ??= ModalRoute.of(context)!.settings.arguments as ChildProfile?;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _postNote() async {
    if (_child == null || _noteController.text.trim().isEmpty) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _posting = true);
    try {
      await _db.addHandoverNote(HandoverNote(
        noteId:     '',
        childId:    _child!.childId,
        authorId:   user.userId,
        authorName: user.name,
        content:    _noteController.text.trim(),
        timestamp:  DateTime.now(),
      ));
      _noteController.clear();
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _posting = false);
  }

  String _fmt(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final role   = Provider.of<AuthProvider>(context, listen: false).role;
    final canAdd = role == 'caregiver';

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
                  Expanded(
                    child: Text(
                      "${_child?.name ?? ''} — Handover Notes",
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _child == null
                  ? const Center(child: Text('Child not found.'))
                  : StreamBuilder<List<HandoverNote>>(
                stream: _db.streamHandoverNotes(_child!.childId),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        color: AppColors.sageGreen));
                  }
                  final notes = snap.data ?? [];
                  if (notes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sticky_note_2_outlined,
                                color: AppColors.dustyGray, size: 60),
                            const SizedBox(height: 16),
                            Text(
                              canAdd
                                  ? 'No notes yet.\nLeave a note for the parent below.'
                                  : 'No handover notes yet.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.darkGray),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (_, i) {
                      final note = notes[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.warmBeige,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.darkGray,
                                )),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  note.authorName.isNotEmpty
                                      ? note.authorName
                                      : 'Caregiver',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.sageGreen,
                                  ),
                                ),
                                Text(_fmt(note.timestamp),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.dustyGray,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // compose box — caregiver only
            if (canAdd)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        minLines:   1,
                        maxLines:   4,
                        decoration: InputDecoration(
                          hintText: "How was the child's day?",
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
                          fillColor: Colors.white,
                          filled:    true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _posting ? null : _postNote,
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _posting
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Icon(Icons.send,
                            color: Colors.white, size: 20),
                      ),
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
