import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/overstimulation_event.dart';
import '../../providers/child_provider.dart';
import '../../services/audio_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class ChildAlertScreen extends StatefulWidget {
  const ChildAlertScreen({super.key});

  @override
  State<ChildAlertScreen> createState() => _ChildAlertScreenState();
}

class _ChildAlertScreenState extends State<ChildAlertScreen> {
  final AudioService     _audio = AudioService();
  final FirestoreService _db    = FirestoreService();
  String? _eventId;
  String? _childId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _childId = Provider.of<ChildProvider>(context, listen: false)
          .childProfile?.childId ?? '';
      _audio.playWhiteNoise(childId: _childId);
      _logEvent();
    });
  }

  Future<void> _logEvent() async {
    final child = Provider.of<ChildProvider>(context, listen: false);
    if (child.childProfile == null) {
      debugPrint('SAFESENSE DEBUG: childProfile is null, cannot log event');
      return;
    }

    debugPrint('SAFESENSE DEBUG: linkedUserIds = ${child.childProfile!.linkedUserIds}');

    try {
      final eventDateTime = DateTime.now();
      final event = OverstimulationEvent(
        eventId:      '',
        childId:      child.childProfile!.childId,
        eventType:    'child-initiated',
        dateTime:     eventDateTime,
        notes:        '',
        audioStopped: false,
      );
      final id = await _db.addEvent(event);
      debugPrint('SAFESENSE DEBUG: event created with id = $id');

      await _db.notifyLinkedUsers(
        child:    child.childProfile!,
        eventId:  id,
        dateTime: eventDateTime,
      );
      debugPrint('SAFESENSE DEBUG: notifications sent');

      if (mounted) setState(() => _eventId = id);
    } catch (e, stack) {
      debugPrint('SAFESENSE ERROR: $e');
      debugPrint('SAFESENSE STACK: $stack');
    }
  }

  Future<void> _stop() async {
    if (_eventId != null && _childId != null) {
      try {
        await _db.updateEvent(OverstimulationEvent(
          eventId:      _eventId!,
          childId:      _childId!,
          eventType:    'child-initiated',
          dateTime:     DateTime.now(),
          notes:        '',
          audioStopped: true,
        ));
      } catch (_) {}
    }
    _audio.stop();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              const Center(
                child: Icon(Icons.favorite,
                    color: AppColors.darkGray, size: 60),
              ),
              const SizedBox(height: 32),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'You are safe.\nLet\'s take some deep\nbreaths together.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   24,
                    fontWeight: FontWeight.bold,
                    color:      AppColors.darkGray,
                    height:     1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up,
                          color: AppColors.darkGray, size: 20),
                      SizedBox(width: 8),
                      Text('White noise is playing...',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.darkGray)),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 40),
                child: GestureDetector(
                  onTap: _stop,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color:        AppColors.warmBeige,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text('Stop',
                          style: TextStyle(
                            fontSize:   22,
                            fontWeight: FontWeight.bold,
                            color:      AppColors.darkGray,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}