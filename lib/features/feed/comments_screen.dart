import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../models/comment.dart';
import '../../utils/time_formatter.dart';
import '../../widgets/user_avatar.dart';

class CommentsScreen extends StatefulWidget {
  final FeedPost post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final List<Comment> _comments = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Comment? _replyingTo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _comments.addAll(_getMockComments());
      _isLoading = false;
    });
  }

  void _addComment() {
    if (_controller.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().toString(),
      postId: widget.post.id,
      userId: 'current_user',
      username: 'You',
      content: _controller.text.trim(),
      createdAt: DateTime.now(),
      parentCommentId: _replyingTo?.id,
    );

    setState(() {
      if (_replyingTo != null) {
        // Add as a reply to an existing comment
        _addReplyToComment(_comments, newComment);
      } else {
        _comments.insert(0, newComment);
      }
      _controller.clear();
      _replyingTo = null;
    });

    _focusNode.unfocus();
  }

  void _addReplyToComment(List<Comment> comments, Comment reply) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == reply.parentCommentId) {
        comments[i] = comments[i].copyWith(
          replies: [...comments[i].replies, reply],
        );
        return;
      }
      if (comments[i].replies.isNotEmpty) {
        _addReplyToComment(comments[i].replies, reply);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Original Post
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha:0.05),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      imageUrl: widget.post.userAvatar,
                      name: widget.post.username,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            TimeFormatter.getRelativeTime(widget.post.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return _buildCommentItem(_comments[index]);
              },
            ),
          ),

          // Reply indicator
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha:0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingTo!.username}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      setState(() => _replyingTo = null);
                    },
                  ),
                ],
              ),
            ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha:0.05),
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const UserAvatar(
                      name: 'Current User',
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B6CEE),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, size: 20),
                        color: Colors.white,
                        onPressed: _addComment,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, {int level = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16 + (level * 40.0),
            12,
            16,
            4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                imageUrl: comment.userAvatar,
                name: comment.username,
                size: level == 0 ? 36 : 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          TimeFormatter.getRelativeTime(comment.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCommentAction(
                          icon: comment.isLikedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: comment.likes > 0
                              ? TimeFormatter.formatCompactNumber(comment.likes)
                              : 'Like',
                          color: comment.isLikedByCurrentUser
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF94A3B8),
                          onTap: () => _likeComment(comment),
                        ),
                        const SizedBox(width: 16),
                        if (level < 2) // Limit nesting to 2 levels
                          _buildCommentAction(
                            icon: Icons.reply,
                            label: 'Reply',
                            color: const Color(0xFF94A3B8),
                            onTap: () {
                              setState(() => _replyingTo = comment);
                              _focusNode.requestFocus();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Nested replies
        if (comment.replies.isNotEmpty)
          ...comment.replies.map((reply) {
            return _buildCommentItem(reply, level: level + 1);
          }),
      ],
    );
  }

  Widget _buildCommentAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.1),
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No comments yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to comment!',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _likeComment(Comment comment) {
    setState(() {
      _updateCommentLike(_comments, comment.id);
    });
  }

  void _updateCommentLike(List<Comment> comments, String commentId) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == commentId) {
        final isLiked = comments[i].isLikedByCurrentUser;
        comments[i] = comments[i].copyWith(
          likes: isLiked ? comments[i].likes - 1 : comments[i].likes + 1,
          isLikedByCurrentUser: !isLiked,
        );
        return;
      }
      if (comments[i].replies.isNotEmpty) {
        _updateCommentLike(comments[i].replies, commentId);
      }
    }
  }

  List<Comment> _getMockComments() {
    return [
      Comment(
        id: '1',
        postId: widget.post.id,
        userId: 'user2',
        username: 'Rahul Singh',
        content: 'This is amazing! Would love to know more about the tech stack you used.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        likes: 3,
        replies: [
          Comment(
            id: '1-1',
            postId: widget.post.id,
            userId: 'user1',
            username: 'Akhil Kumar',
            content: 'Thanks! We used Flutter for the frontend and Node.js with Firebase for the backend.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
            likes: 1,
            parentCommentId: '1',
          ),
        ],
      ),
      Comment(
        id: '2',
        postId: widget.post.id,
        userId: 'user3',
        username: 'Sneha Reddy',
        content: 'Congratulations! 🎉 Your project looks really impressive.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        likes: 5,
      ),
      Comment(
        id: '3',
        postId: widget.post.id,
        userId: 'user4',
        username: 'Amit Patel',
        content: 'Would you be interested in collaborating on a similar project?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 2,
      ),
    ];
  }
}