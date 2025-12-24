class UserModel {
  final String id;
  final String name;
  final String email;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final String? department;
  final String? year; // Freshman, Sophomore, Junior, Senior, Graduate
  final List<String> interests;
  final List<String> skills;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;
  final DateTime? lastActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.bio,
    this.avatarUrl,
    this.department,
    this.year,
    this.interests = const [],
    this.skills = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    required this.createdAt,
    this.lastActive,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? bio,
    String? avatarUrl,
    String? department,
    String? year,
    List<String>? interests,
    List<String>? skills,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      year: year ?? this.year,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'department': department,
      'year': year,
      'interests': interests,
      'skills': skills,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      department: json['department'] as String?,
      year: json['year'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
    );
  }
}