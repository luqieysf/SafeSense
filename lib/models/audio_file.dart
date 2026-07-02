class AudioFile {
  final String audioId;
  final String childId;
  final String fileName;
  final String fileType;   // MP3 / WAV
  final bool   isDefault;  // false = custom upload
  final String storageUrl;

  AudioFile({
    required this.audioId,
    required this.childId,
    required this.fileName,
    required this.fileType,
    required this.isDefault,
    required this.storageUrl,
  });

  factory AudioFile.fromMap(String id, Map<String, dynamic> map) {
    return AudioFile(
      audioId:    id,
      childId:    map['childId']    ?? '',
      fileName:   map['fileName']   ?? '',
      fileType:   map['fileType']   ?? 'MP3',
      isDefault:  map['isDefault']  ?? true,
      storageUrl: map['storageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId':    childId,
      'fileName':   fileName,
      'fileType':   fileType,
      'isDefault':  isDefault,
      'storageUrl': storageUrl,
    };
  }
}