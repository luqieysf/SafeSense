import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/child_profile.dart';
import '../models/overstimulation_event.dart';
import '../models/routine_task.dart';

class PdfService {
  // main entry point — generates and shares PDF
  static Future<void> generateAndShare({
    required ChildProfile         child,
    required String               month,
    required List<OverstimulationEvent> events,
    required List<RoutineTask>    tasks,
    required String               generatedBy,
  }) async {
    final pdf = pw.Document();

    // parse month
    final parts      = month.split('-');
    final monthNames = ['January','February','March','April','May','June',
      'July','August','September','October','November',
      'December'];
    final monthName  = parts.length >= 2
        ? '${monthNames[(int.tryParse(parts[1]) ?? 1) - 1]} ${parts[0]}'
        : month;

    // stats
    final totalEvents     = events.length;
    final childInitiated  = events
        .where((e) => e.eventType == 'child-initiated').length;
    final manualEvents    = events
        .where((e) => e.eventType == 'manual').length;
    final completedTasks  = tasks.where((t) => t.isCompleted).length;
    final totalTasks      = tasks.length;
    final completionRate  = totalTasks > 0
        ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
        : '0.0';

    // colors
    const headerColor   = PdfColor.fromInt(0xFF9CAF88); // sage green
    const softBlue      = PdfColor.fromInt(0xFFADD8E6);
    const lavender      = PdfColor.fromInt(0xFFE6E6FA);
    const warmBeige     = PdfColor.fromInt(0xFFF5E6D3);
    const pastelTeal    = PdfColor.fromInt(0xFF7DD3C0);
    const darkGray      = PdfColor.fromInt(0xFF333333);
    const lightGray     = PdfColor.fromInt(0xFFF5F5DC);

    pdf.addPage(
      pw.MultiPage(
        pageFormat:   PdfPageFormat.a4,
        margin:       const pw.EdgeInsets.all(32),
        header:       (ctx) => _buildHeader(
            monthName, child.name, darkGray, headerColor),
        footer:       (ctx) => _buildFooter(
            ctx, generatedBy, darkGray),
        build:        (ctx) => [

          // ── Child Info Section ──────────────────────────────────────
          _sectionTitle('Child Information', darkGray),
          pw.SizedBox(height: 8),
          pw.Container(
            padding:    const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color:        lavender,
              borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Name',              child.name,             darkGray),
                _infoRow('Token Balance',     '${child.tokenBalance} tokens', darkGray),
                _infoRow('Noise Sensitivity', child.noiseSensitivity.toUpperCase(), darkGray),
                _infoRow('Light Sensitivity', child.lightSensitivity.toUpperCase(), darkGray),
                _infoRow('Language',          child.language,         darkGray),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Event Summary Section ───────────────────────────────────
          _sectionTitle('Event Summary — $monthName', darkGray),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            _statBox('Total\nEvents',    '$totalEvents',    softBlue,   darkGray),
            pw.SizedBox(width: 8),
            _statBox('Child\nInitiated', '$childInitiated', warmBeige,  darkGray),
            pw.SizedBox(width: 8),
            _statBox('Manually\nLogged', '$manualEvents',   pastelTeal, darkGray),
          ]),
          pw.SizedBox(height: 20),

          // ── Routine Summary Section ─────────────────────────────────
          _sectionTitle('Routine Completion', darkGray),
          pw.SizedBox(height: 8),
          pw.Container(
            padding:    const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color:        lightGray,
              borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Tasks Completed',
                    style: pw.TextStyle(
                        fontSize: 12, color: darkGray,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('$completedTasks / $totalTasks  ($completionRate%)',
                    style: pw.TextStyle(
                        fontSize: 12, color: darkGray)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Event List Section ──────────────────────────────────────
          _sectionTitle('Event Log', darkGray),
          pw.SizedBox(height: 8),

          if (events.isEmpty)
            pw.Container(
              padding:    const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color:        lightGray,
                borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8)),
              ),
              child: pw.Center(
                child: pw.Text(
                    'No events recorded for $monthName.',
                    style: pw.TextStyle(
                        fontSize: 11, color: darkGray)),
              ),
            )
          else
            ...events.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final bgColor = i.isEven ? lightGray : lavender;
              return pw.Container(
                margin:     const pw.EdgeInsets.only(bottom: 8),
                padding:    const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color:        bgColor,
                  borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          e.eventType == 'child-initiated'
                              ? '🔴 Child Initiated'
                              : '🔵 Manually Logged',
                          style: pw.TextStyle(
                            fontSize:   11,
                            fontWeight: pw.FontWeight.bold,
                            color:      darkGray,
                          ),
                        ),
                        pw.Text(
                          _formatDt(e.dateTime),
                          style: pw.TextStyle(
                              fontSize: 10, color: darkGray),
                        ),
                      ],
                    ),
                    if (e.notes.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Notes: ${e.notes}',
                        style: pw.TextStyle(
                            fontSize: 10, color: darkGray),
                      ),
                    ],
                    if (e.audioStopped) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '✓ Child stopped white noise manually',
                        style: pw.TextStyle(
                            fontSize: 9,
                            color: const PdfColor.fromInt(0xFF9CAF88)),
                      ),
                    ],
                  ],
                ),
              );
            }),

          pw.SizedBox(height: 20),

          // ── Task List Section ───────────────────────────────────────
          if (tasks.isNotEmpty) ...[
            _sectionTitle('Routine Tasks', darkGray),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                color: const PdfColor.fromInt(0xFFB0B0B0),
                width: 0.5,
              ),
              children: [
                // header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: headerColor),
                  children: [
                    _tableCell('Task', darkGray, isHeader: true),
                    _tableCell('Icon', darkGray, isHeader: true),
                    _tableCell('Tokens', darkGray, isHeader: true),
                    _tableCell('Status', darkGray, isHeader: true),
                  ],
                ),
                // task rows
                ...tasks.map((t) => pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: t.isCompleted
                        ? const PdfColor.fromInt(0xFFE8F5E9)
                        : lightGray,
                  ),
                  children: [
                    _tableCell(t.taskName,      darkGray),
                    _tableCell(t.icon,          darkGray),
                    _tableCell('+${t.tokensEarned}', darkGray),
                    _tableCell(
                      t.isCompleted ? 'Done ✓' : 'Pending',
                      t.isCompleted
                          ? const PdfColor.fromInt(0xFF388E3C)
                          : darkGray,
                    ),
                  ],
                )),
              ],
            ),
          ],
        ],
      ),
    );

    // share via Android share sheet
    await Printing.sharePdf(
      bytes:    await pdf.save(),
      filename: 'SafeSense_${child.name}_$month.pdf',
    );
  }

  // ── Helper widgets ───────────────────────────────────────────────────────

  static pw.Widget _buildHeader(
      String monthName, String childName,
      PdfColor darkGray, PdfColor headerColor,
      ) {
    return pw.Container(
      padding:    const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
              color: PdfColor.fromInt(0xFF9CAF88), width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('SafeSense',
                  style: pw.TextStyle(
                    fontSize:   22,
                    fontWeight: pw.FontWeight.bold,
                    color:      headerColor,
                  )),
              pw.Text('Monthly Progress Report',
                  style: pw.TextStyle(
                      fontSize: 11, color: darkGray)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(childName,
                  style: pw.TextStyle(
                    fontSize:   14,
                    fontWeight: pw.FontWeight.bold,
                    color:      darkGray,
                  )),
              pw.Text(monthName,
                  style: pw.TextStyle(
                      fontSize: 11, color: darkGray)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(
      pw.Context ctx, String generatedBy, PdfColor darkGray) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
              color: PdfColor.fromInt(0xFFB0B0B0), width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by: $generatedBy',
            style: pw.TextStyle(fontSize: 9, color: darkGray),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: darkGray),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize:   13,
        fontWeight: pw.FontWeight.bold,
        color:      color,
      ),
    );
  }

  static pw.Widget _infoRow(
      String label, String value, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(label,
                style: pw.TextStyle(
                  fontSize:   11,
                  fontWeight: pw.FontWeight.bold,
                  color:      color,
                )),
          ),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _statBox(
      String label, String value,
      PdfColor bgColor, PdfColor textColor,
      ) {
    return pw.Expanded(
      child: pw.Container(
        padding:    const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color:        bgColor,
          borderRadius: const pw.BorderRadius.all(
              pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                  fontSize:   20,
                  fontWeight: pw.FontWeight.bold,
                  color:      textColor,
                )),
            pw.SizedBox(height: 4),
            pw.Text(label,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: 9, color: textColor)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
      String text, PdfColor color, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize:   10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          color:      color,
        ),
      ),
    );
  }

  static String _formatDt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
}