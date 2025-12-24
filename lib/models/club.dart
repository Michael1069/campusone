class Club {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final String? bannerUrl;
  final String category; // Technical, Sports, Arts, Academic, Social
  final List<String> tags;
  final int membersCount;
  final bool isCurrentUserMember;
  final DateTime createdAt;
  final String? meetingSchedule;
  final String? location;
  final List<ClubEvent> upcomingEvents;

  Club({
    required this.id,
    required this.name,
    required this.description,
    this.avatarUrl,
    this.bannerUrl,
    required this.category,
    this.tags = const [],
    this.membersCount = 0,
    this.isCurrentUserMember = false,
    required this.createdAt,
    this.meetingSchedule,
    this.location,
    this.upcomingEvents = const [],
  });

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? bannerUrl,
    String? category,
    List<String>? tags,
    int? membersCount,
    bool? isCurrentUserMember,
    DateTime? createdAt,
    String? meetingSchedule,
    String? location,
    List<ClubEvent>? upcomingEvents,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      membersCount: membersCount ?? this.membersCount,
      isCurrentUserMember: isCurrentUserMember ?? this.isCurrentUserMember,
      createdAt: createdAt ?? this.createdAt,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      location: location ?? this.location,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'category': category,
      'tags': tags,
      'membersCount': membersCount,
      'isCurrentUserMember': isCurrentUserMember,
      'createdAt': createdAt.toIso8601String(),
      'meetingSchedule': meetingSchedule,
      'location': location,
      'upcomingEvents': upcomingEvents.map((e) => e.toJson()).toList(),
    };
  }

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      membersCount: json['membersCount'] as int? ?? 0,
      isCurrentUserMember: json['isCurrentUserMember'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      meetingSchedule: json['meetingSchedule'] as String?,
      location: json['location'] as String?,
      upcomingEvents: (json['upcomingEvents'] as List<dynamic>?)
          ?.map((e) => ClubEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class ClubEvent {
  final String id;
  final String clubId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final bool isOnline;
  final int attendeesCount;
  final bool isCurrentUserAttending;

  ClubEvent({
    required this.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.startTime,
    this.endTime,
    this.location,
    this.isOnline = false,
    this.attendeesCount = 0,
    this.isCurrentUserAttending = false,
  });

  ClubEvent copyWith({
    String? id,
    String? clubId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isOnline,
    int? attendeesCount,
    bool? isCurrentUserAttending,
  }) {
    return ClubEvent(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      isCurrentUserAttending: isCurrentUserAttending ?? this.isCurrentUserAttending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubId': clubId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'isOnline': isOnline,
      'attendeesCount': attendeesCount,
      'isCurrentUserAttending': isCurrentUserAttending,
    };
  }

  factory ClubEvent.fromJson(Map<String, dynamic> json) {
    return ClubEvent(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      location: json['location'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      attendeesCount: json['attendeesCount'] as int? ?? 0,
      isCurrentUserAttending: json['isCurrentUserAttending'] as bool? ?? false,
    );
  }
}