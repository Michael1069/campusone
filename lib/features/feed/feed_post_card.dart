import 'package:flutter/material.dart';
import 'feed_post.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: onLike,
                ),
                Text(post.likes.toString()),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: onComment,
                ),
                Text(post.comments.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
