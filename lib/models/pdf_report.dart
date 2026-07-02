class PdfReport {
  final String reportId;
  final String childId;
  final String userId;       // caregiver or teacher who generated it
  final String month;        // format: "2026-08"
  final String downloadUrl;

  PdfReport({
    required this.reportId,
    required this.childId,
    required this.userId,
    required this.month,
    required this.downloadUrl,
  });

  factory PdfReport.fromMap(String id, Map<String, dynamic> map) {
    return PdfReport(
      reportId:    id,
      childId:     map['childId']     ?? '',
      userId:      map['userId']      ?? '',
      month:       map['month']       ?? '',
      downloadUrl: map['downloadUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId':     childId,
      'userId':      userId,
      'month':       month,
      'downloadUrl': downloadUrl,
    };
  }
}