import 'package:flutter/material.dart';
import '../models/overstimulation_event.dart';
import '../models/event_note.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  List<OverstimulationEvent> _events      = [];
  List<EventNote>            _notes       = [];
  bool                       _isLoading   = false;
  String?                    _errorMessage;

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<OverstimulationEvent> get events       => _events;
  List<EventNote>            get notes        => _notes;
  bool                       get isLoading    => _isLoading;
  String?                    get errorMessage => _errorMessage;

  // ─── Load events for a child ───────────────────────────────────────────────
  Future<void> loadEvents(String childId) async {
    _setLoading(true);
    try {
      _events = await _db.getEvents(childId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // ─── Add event ─────────────────────────────────────────────────────────────
  Future<void> addEvent(OverstimulationEvent event) async {
    try {
      final newId = await _db.addEvent(event);
      _events.insert(0, OverstimulationEvent(
        eventId:      newId,
        childId:      event.childId,
        eventType:    event.eventType,
        dateTime:     event.dateTime,
        notes:        event.notes,
        audioStopped: event.audioStopped,
      ));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ─── Load notes for an event ───────────────────────────────────────────────
  Future<void> loadNotes(String eventId) async {
    _setLoading(true);
    try {
      _notes = await _db.getNotes(eventId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // ─── Add note to event ─────────────────────────────────────────────────────
  Future<void> addNote(EventNote note) async {
    try {
      await _db.addNote(note);
      _notes.add(note);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearEvents() {
    _events = [];
    _notes  = [];
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}