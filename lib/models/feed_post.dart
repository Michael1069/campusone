class FeedPost {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String? userDepartment;
  final String content;
  final List<String> imageUrls;
  final String? linkUrl;
  final String? linkTitle;
  final String? linkDescription;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int shares;
  final bool isLikedByCurrentUser;
  final bool isBookmarked;
  final List<String> tags;
  final PostType type; // text, image, link, poll, event

  FeedPost({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    this.userDepartment,
    required this.content,
    this.imageUrls = const [],
    this.linkUrl,
    this.linkTitle,
    this.linkDescription,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLikedByCurrentUser = false,
    this.isBookmarked = false,
    this.tags = const [],
    this.type = PostType.text,
  });

  FeedPost copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? userDepartment,
    String? content,
    List<String>? imageUrls,
    String? linkUrl,
    String? linkTitle,
    String? linkDescription,
    DateTime? createdAt,
    int? likes,
    int? comments,
    int? shares,
    bool? isLikedByCurrentUser,
    bool? isBookmarked,
    List<String>? tags,
    PostType? type,
  }) {
    return FeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      userDepartment: userDepartment ?? this.userDepartment,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      linkUrl: linkUrl ?? this.linkUrl,
      linkTitle: linkTitle ?? this.linkTitle,
      linkDescription: linkDescription ?? this.linkDescription,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'userDepartment': userDepartment,
      'content': content,
      'imageUrls': imageUrls,
      'linkUrl': linkUrl,
      'linkTitle': linkTitle,
      'linkDescription': linkDescription,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'isBookmarked': isBookmarked,
      'tags': tags,
      'type': type.toString(),
    };
  }

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String?,
      userDepartment: json['userDepartment'] as String?,
      content: json['content'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      linkUrl: json['linkUrl'] as String?,
      linkTitle: json['linkTitle'] as String?,
      linkDescription: json['linkDescription'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      type: PostType.values.firstWhere(
            (e) => e.toString() == json['type'],
        orElse: () => PostType.text,
      ),
    );
  }
}

enum PostType {
  text,
  image,
  link,
  poll,
  event,
}