import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/child_profile.dart';
import '../../models/overstimulation_event.dart';
import '../../models/routine_task.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _db = FirestoreService();

  List<ChildProfile>         _children        = [];
  List<OverstimulationEvent> _events          = [];
  List<RoutineTask>          _tasks           = [];
  ChildProfile?              _selected;
  bool                       _loadingChildren = true;
  bool                       _loadingEvents   = false;
  bool                       _generatingPdf   = false;

  late String       _month;
  late List<String> _months;

  @override
  void initState() {
    super.initState();
    _months = _generateMonths();
    _month  = _months.first;
    _loadData();
  }

  List<String> _generateMonths() {
    final now    = DateTime.now();
    final result = <String>[];
    for (int i = 0; i < 6; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      result.add('${d.year}-${d.month.toString().padLeft(2, '0')}');
    }
    return result;
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ids  = auth.currentUser?.linkedChildIds ?? [];
    final list = await _db.getChildrenForUser(ids);

    if (mounted) {
      setState(() {
        _children        = list;
        _selected        = list.isNotEmpty ? list.first : null;
        _loadingChildren = false;
      });
      if (_selected != null) _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    if (_selected == null) return;
    setState(() => _loadingEvents = true);

    final events = await _db.getEventsByMonth(_selected!.childId, _month);
    final tasks  = await _db.getTasks(_selected!.childId);

    if (mounted) {
      setState(() {
        _events       = events;
        _tasks        = tasks;
        _loadingEvents = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_selected == null) return;
    setState(() => _generatingPdf = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await PdfService.generateAndShare(
        child:       _selected!,
        month:       _month,
        events:      _events,
        tasks:       _tasks,
        generatedBy: auth.currentUser?.name ?? 'SafeSense',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')));
    }

    if (mounted) setState(() => _generatingPdf = false);
  }

  String _fmtMonth(String m) {
    final p = m.split('-');
    if (p.length < 2) return m;
    final names = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    final idx = (int.tryParse(p[1]) ?? 1) - 1;
    return '${names[idx]} ${p[0]}';
  }

  String _fmtDt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour.toString().padLeft(2,'0')}:'
          '${dt.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // header
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
                  const Text('Monthly Report',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                ],
              ),
            ),

            Expanded(
              child: _loadingChildren
                  ? const Center(child: CircularProgressIndicator(
                  color: AppColors.sageGreen))
                  : _children.isEmpty
                  ? const Center(child: Text(
                  'No children linked.',
                  style: TextStyle(color: AppColors.darkGray)))
                  : ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // child selector
                  const Text('Select Child',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 8),
                  _dropdown(
                    color: AppColors.softBlue,
                    child: DropdownButton<ChildProfile>(
                      value:         _selected,
                      isExpanded:    true,
                      dropdownColor: AppColors.softBlue,
                      onChanged:     (v) {
                        setState(() => _selected = v);
                        _loadEvents();
                      },
                      items: _children.map((c) =>
                          DropdownMenuItem(
                            value: c,
                            child: Text(c.name,
                                style: const TextStyle(
                                    color: AppColors.darkGray)),
                          )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // month selector
                  const Text('Select Month',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 8),
                  _dropdown(
                    color: AppColors.pastelTeal,
                    child: DropdownButton<String>(
                      value:         _month,
                      isExpanded:    true,
                      dropdownColor: AppColors.pastelTeal,
                      onChanged:     (v) {
                        setState(() => _month = v!);
                        _loadEvents();
                      },
                      items: _months.map((m) =>
                          DropdownMenuItem(
                            value: m,
                            child: Text(_fmtMonth(m),
                                style: const TextStyle(
                                    color: AppColors.darkGray)),
                          )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // stats card
                  if (_selected != null && !_loadingEvents) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lavender,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        Text(
                          '${_selected!.name} — ${_fmtMonth(_month)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatBox(
                                label: 'Total',
                                value: '${_events.length}',
                                color: AppColors.warmBeige),
                            _StatBox(
                                label: 'Child',
                                value: '${_events.where((e) => e.eventType == 'child-initiated').length}',
                                color: AppColors.softBlue),
                            _StatBox(
                                label: 'Manual',
                                value: '${_events.where((e) => e.eventType == 'manual').length}',
                                color: AppColors.pastelTeal),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // routine stats
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Task Completion',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGray,
                                  )),
                              Text(
                                '${_tasks.where((t) => t.isCompleted).length}'
                                    ' / ${_tasks.length} tasks',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // generate PDF button
                    ElevatedButton.icon(
                      onPressed: _generatingPdf
                          ? null
                          : _generatePdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sageGreen,
                        foregroundColor: Colors.white,
                        minimumSize:
                        const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: _generatingPdf
                          ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color:       Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(_generatingPdf
                          ? 'Generating PDF...'
                          : 'Generate & Share PDF'),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // event list preview
                  const Text('Events This Month',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      )),
                  const SizedBox(height: 10),

                  if (_loadingEvents)
                    const Center(child: CircularProgressIndicator(
                        color: AppColors.sageGreen))
                  else if (_events.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.warmBeige,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                          'No events recorded this month.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.darkGray)),
                    )
                  else
                    ..._events.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: e.eventType == 'child-initiated'
                            ? AppColors.warmBeige
                            : AppColors.softBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(
                                e.eventType == 'child-initiated'
                                    ? Icons.child_care
                                    : Icons.edit,
                                color: AppColors.darkGray,
                                size: 16),
                            const SizedBox(width: 8),
                            Text(
                              e.eventType == 'child-initiated'
                                  ? 'Child Initiated'
                                  : 'Manually Logged',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGray,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text(_fmtDt(e.dateTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGray,
                              )),
                          if (e.notes.isNotEmpty)
                            Text(e.notes,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGray,
                                )),
                        ],
                      ),
                    )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({required Color color, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _StatBox({
    required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold,
          color: AppColors.darkGray)),
      Text(label, style: const TextStyle(
          fontSize: 10, color: AppColors.darkGray),
          textAlign: TextAlign.center),
    ]),
  );
}
