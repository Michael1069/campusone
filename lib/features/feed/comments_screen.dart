import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/feed_post.dart';
import '../../models/comment.dart';
import '../../core/services/comment_service.dart';
import '../../utils/time_formatter.dart';
import '../../widgets/user_avatar.dart';

class CommentsScreen extends StatefulWidget {
  final FeedPost post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  List<Comment> _comments = [];
  Comment? _replyingTo;
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);

    final comments = await _commentService.getComments(widget.post.id);

    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    // Get the parent comment ID (always the top-level comment)
    String? parentId;
    if (_replyingTo != null) {
      // If replying to a reply, use its parent (the top-level comment)
      parentId = _replyingTo!.parentCommentId ?? _replyingTo!.id;
    }

    final commentId = await _commentService.addComment(
      postId: widget.post.id,
      content: _controller.text.trim(),
      parentId: parentId,
    );

    if (commentId != null) {
      _controller.clear();
      setState(() {
        _replyingTo = null;
        _isPosting = false;
      });
      _focusNode.unfocus();
      
      // Reload comments to show the new one
      _loadComments();
    } else {
      setState(() => _isPosting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleLike(Comment comment) async {
    // Optimistic update
    setState(() {
      _updateCommentLike(_comments, comment.id);
    });

    // Update in Firebase
    await _commentService.toggleLike(comment.id, comment.isLikedByCurrentUser);
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
      // Also check in replies
      for (int j = 0; j < comments[i].replies.length; j++) {
        if (comments[i].replies[j].id == commentId) {
          final reply = comments[i].replies[j];
          final isLiked = reply.isLikedByCurrentUser;
          comments[i].replies[j] = reply.copyWith(
            likes: isLiked ? reply.likes - 1 : reply.likes + 1,
            isLikedByCurrentUser: !isLiked,
          );
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
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
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 8),
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
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2B6CEE),
                    ),
                  )
                : _comments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
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
                    color: Colors.white.withValues(alpha: 0.05),
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
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _replyingTo = null;
                        _controller.clear();
                      });
                    },
                  ),
                ],
              ),
            ),

          // Comment Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    UserAvatar(
                      imageUrl: currentUser?.photoURL,
                      name: currentUser?.displayName ?? 'U',
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 120,
                        ),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B6CEE),
                        shape: BoxShape.circle,
                      ),
                      child: _isPosting
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : IconButton(
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

  Widget _buildCommentItem(Comment comment) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                imageUrl: comment.userAvatar,
                name: comment.username,
                size: 36,
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
                          onTap: () => _toggleLike(comment),
                        ),
                        const SizedBox(width: 16),
                        _buildCommentAction(
                          icon: Icons.reply,
                          label: 'Reply',
                          color: const Color(0xFF94A3B8),
                          onTap: () {
                            setState(() => _replyingTo = comment);
                            _controller.text = '@${comment.username} ';
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );
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
        // Display replies
        if (comment.replies.isNotEmpty)
          ...comment.replies.map((reply) => _buildReplyItem(reply)),
      ],
    );
  }

  Widget _buildReplyItem(Comment reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 16, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: reply.userAvatar,
            name: reply.username,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      TimeFormatter.getRelativeTime(reply.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reply.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildCommentAction(
                      icon: reply.isLikedByCurrentUser
                          ? Icons.favorite
                          : Icons.favorite_border,
                      label: reply.likes > 0
                          ? TimeFormatter.formatCompactNumber(reply.likes)
                          : 'Like',
                      color: reply.isLikedByCurrentUser
                          ? const Color(0xFFEC4899)
                          : const Color(0xFF94A3B8),
                      onTap: () => _toggleLike(reply),
                    ),
                    const SizedBox(width: 16),
                    _buildCommentAction(
                      icon: Icons.reply,
                      label: 'Reply',
                      color: const Color(0xFF94A3B8),
                      onTap: () {
                        setState(() => _replyingTo = reply);
                        _controller.text = '@${reply.username} ';
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: _controller.text.length),
                        );
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
                color: Colors.white.withValues(alpha: 0.1),
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
}
