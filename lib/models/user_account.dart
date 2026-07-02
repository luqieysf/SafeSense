class UserAccount {
  final String       userId;
  final String       name;
  final String       email;
  final String       role;
  final List<String> linkedChildIds;
  final String       profileImageUrl;

  UserAccount({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.linkedChildIds,
    this.profileImageUrl = '',
  });

  factory UserAccount.fromMap(String id, Map<String, dynamic> map) {
    return UserAccount(
      userId:          id,
      name:            map['name']            ?? '',
      email:           map['email']           ?? '',
      role:            map['role']            ?? 'parent',
      linkedChildIds:  List<String>.from(map['linkedChildIds'] ?? []),
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name':            name,
    'email':           email,
    'role':            role,
    'linkedChildIds':  linkedChildIds,
    'profileImageUrl': profileImageUrl,
  };

  UserAccount copyWith({
    String? name, String? email, String? role,
    List<String>? linkedChildIds, String? profileImageUrl,
  }) => UserAccount(
    userId:          userId,
    name:            name            ?? this.name,
    email:           email           ?? this.email,
    role:            role            ?? this.role,
    linkedChildIds:  linkedChildIds  ?? this.linkedChildIds,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
  );
}