import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../utils/time_formatter.dart';
import 'user_avatar.dart';

class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onUserTap;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onShare,
    this.onBookmark,
    this.onUserTap,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  bool _isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onLike();
    setState(() => _isLikeAnimating = true);
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
      setState(() => _isLikeAnimating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: UserAvatar(
                    imageUrl: widget.post.userAvatar,
                    name: widget.post.username,
                    size: 44,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onUserTap,
                        child: Text(
                          widget.post.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (widget.post.userDepartment != null) ...[
                            Text(
                              widget.post.userDepartment!,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '•',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ],
                          Text(
                            TimeFormatter.getRelativeTime(widget.post.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.post.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),

          // Tags
          if (widget.post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B6CEE).withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF2B6CEE).withValues(alpha:0.3),
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Images
          if (widget.post.imageUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildImageGrid(),
            ),

          // Link Preview
          if (widget.post.linkUrl != null) _buildLinkPreview(),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildActionButton(
                  icon: widget.post.isLikedByCurrentUser
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: TimeFormatter.formatCompactNumber(widget.post.likes),
                  color: widget.post.isLikedByCurrentUser
                      ? const Color(0xFFEC4899)
                      : const Color(0xFF94A3B8),
                  onTap: _handleLike,
                  isAnimating: _isLikeAnimating,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: TimeFormatter.formatCompactNumber(widget.post.comments),
                  color: const Color(0xFF94A3B8),
                  onTap: widget.onComment,
                ),
                const SizedBox(width: 16),
                if (widget.onShare != null)
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: widget.post.shares > 0
                        ? TimeFormatter.formatCompactNumber(widget.post.shares)
                        : '',
                    color: const Color(0xFF94A3B8),
                    onTap: widget.onShare!,
                  ),
                const Spacer(),
                if (widget.onBookmark != null)
                  IconButton(
                    icon: Icon(
                      widget.post.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: widget.post.isBookmarked
                          ? const Color(0xFF2B6CEE)
                          : const Color(0xFF94A3B8),
                    ),
                    onPressed: widget.onBookmark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isAnimating = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            AnimatedScale(
              scale: isAnimating ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, size: 20, color: color),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final images = widget.post.imageUrls;
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images[0],
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 250,
            color: const Color(0xFF0F172A),
            child: const Center(
              child: Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
            ),
          ),
        ),
      );
    } else if (images.length == 2) {
      return Row(
        children: images.map((url) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images.length > 4 ? 4 : images.length,
        itemBuilder: (context, index) {
          final isLast = index == 3 && images.length > 4;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  images[index],
                  fit: BoxFit.cover,
                ),
                if (isLast)
                  Container(
                    color: Colors.black.withValues(alpha:0.6),
                    child: Center(
                      child: Text(
                        '+${images.length - 4}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildLinkPreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha:0.05),
          ),
        ),
        child: InkWell(
          onTap: () {
            // Open link
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.post.linkUrl!,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (widget.post.linkTitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.post.linkTitle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (widget.post.linkDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.post.linkDescription!,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetOption(
                icon: Icons.bookmark_border,
                label: 'Save Post',
                onTap: () {
                  Navigator.pop(context);
                  widget.onBookmark?.call();
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.link,
                label: 'Copy Link',
                onTap: () {
                  Navigator.pop(context);
                  // Copy link logic
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.report_outlined,
                label: 'Report Post',
                onTap: () {
                  Navigator.pop(context);
                  // Report logic
                },
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF94A3B8),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}