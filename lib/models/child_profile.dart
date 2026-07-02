class ChildProfile {
  final String       childId;
  final String       name;
  final String       noiseSensitivity;
  final String       lightSensitivity;
  final int          tokenBalance;
  final String       language;
  final String       deviceId;
  final String       pin;
  final List<String> linkedUserIds;
  final String       profileImageUrl;
  final String       caregiverEmail;
  final int          monthlyEventCount;
  final String       lastEventMonth;   // format: "2026-07"
  final String       classId;

  ChildProfile({
    required this.childId,
    required this.name,
    required this.noiseSensitivity,
    required this.lightSensitivity,
    required this.tokenBalance,
    required this.language,
    required this.deviceId,
    required this.pin,
    required this.linkedUserIds,
    this.profileImageUrl  = '',
    this.caregiverEmail   = '',
    this.monthlyEventCount = 0,
    this.lastEventMonth   = '',
    this.classId          = '',
  });

  factory ChildProfile.fromMap(String id, Map<String, dynamic> map) {
    return ChildProfile(
      childId:           id,
      name:              map['name']              ?? '',
      noiseSensitivity:  map['noiseSensitivity']  ?? 'low',
      lightSensitivity:  map['lightSensitivity']  ?? 'low',
      tokenBalance:      map['tokenBalance']       ?? 0,
      language:          map['language']           ?? 'English',
      deviceId:          map['deviceId']           ?? '',
      pin:               map['pin']                ?? '',
      linkedUserIds:     List<String>.from(map['linkedUserIds']  ?? []),
      profileImageUrl:   map['profileImageUrl']   ?? '',
      caregiverEmail:    map['caregiverEmail']     ?? '',
      monthlyEventCount: map['monthlyEventCount']  ?? 0,
      lastEventMonth:    map['lastEventMonth']     ?? '',
      classId:           map['classId']            ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name':              name,
    'noiseSensitivity':  noiseSensitivity,
    'lightSensitivity':  lightSensitivity,
    'tokenBalance':      tokenBalance,
    'language':          language,
    'deviceId':          deviceId,
    'pin':               pin,
    'linkedUserIds':     linkedUserIds,
    'profileImageUrl':   profileImageUrl,
    'caregiverEmail':    caregiverEmail,
    'monthlyEventCount': monthlyEventCount,
    'lastEventMonth':    lastEventMonth,
    'classId':           classId,
  };

  ChildProfile copyWith({
    String? name, String? noiseSensitivity, String? lightSensitivity,
    int? tokenBalance, String? language, String? deviceId,
    String? pin, List<String>? linkedUserIds, String? profileImageUrl,
    String? caregiverEmail, int? monthlyEventCount,
    String? lastEventMonth, String? classId,
  }) => ChildProfile(
    childId:           childId,
    name:              name              ?? this.name,
    noiseSensitivity:  noiseSensitivity  ?? this.noiseSensitivity,
    lightSensitivity:  lightSensitivity  ?? this.lightSensitivity,
    tokenBalance:      tokenBalance      ?? this.tokenBalance,
    language:          language          ?? this.language,
    deviceId:          deviceId          ?? this.deviceId,
    pin:               pin               ?? this.pin,
    linkedUserIds:     linkedUserIds     ?? this.linkedUserIds,
    profileImageUrl:   profileImageUrl   ?? this.profileImageUrl,
    caregiverEmail:    caregiverEmail    ?? this.caregiverEmail,
    monthlyEventCount: monthlyEventCount ?? this.monthlyEventCount,
    lastEventMonth:    lastEventMonth    ?? this.lastEventMonth,
    classId:           classId          ?? this.classId,
  );
}