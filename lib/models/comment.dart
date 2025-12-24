class Comment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLikedByCurrentUser;
  final String? parentCommentId; // For nested replies
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLikedByCurrentUser = false,
    this.parentCommentId,
    this.replies = const [],
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? isLikedByCurrentUser,
    String? parentCommentId,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'parentCommentId': parentCommentId,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
      parentCommentId: json['parentCommentId'] as String?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((r) => Comment.fromJson(r as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}