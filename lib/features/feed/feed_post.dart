class FeedPost {
  final String id;
  final String username;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;

  FeedPost({
    required this.id,
    required this.username,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  FeedPost copyWith({
    int? likes,
    int? comments,
  }) {
    return FeedPost(
      id: id,
      username: username,
      content: content,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}