import 'package:flutter/material.dart';
import '../../models/overstimulation_event.dart';
import '../../models/child_profile.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class StudentEventsScreen extends StatefulWidget {
  const StudentEventsScreen({super.key});

  @override
  State<StudentEventsScreen> createState() => _StudentEventsScreenState();
}

class _StudentEventsScreenState extends State<StudentEventsScreen> {
  final _db    = FirestoreService();
  ChildProfile? _child;
  bool          _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _child = ModalRoute.of(context)!.settings.arguments as ChildProfile?;
      _init  = true;
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';

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
                  Expanded(
                    child: Text(
                      '${_child?.name ?? ''} — Events',
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
                  : StreamBuilder<List<OverstimulationEvent>>(
                stream: _db.streamEvents(_child!.childId),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.sageGreen));
                  }
                  final events = snap.data ?? [];
                  if (events.isEmpty) {
                    return const Center(
                      child: Text('No events recorded yet.',
                          style: TextStyle(color: AppColors.darkGray)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (_, i) {
                      final e = events[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.eventDetail,
                            arguments: e),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: e.eventType == 'child-initiated'
                                ? AppColors.warmBeige
                                : AppColors.softBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  e.eventType == 'child-initiated'
                                      ? Icons.child_care : Icons.edit,
                                  color: AppColors.darkGray, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.eventType == 'child-initiated'
                                          ? 'Child Initiated'
                                          : 'Manually Logged',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    Text(_fmt(e.dateTime),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.darkGray,
                                        )),
                                    if (e.notes.isNotEmpty)
                                      Text(e.notes,
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkGray,
                                          )),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.darkGray),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}